import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:get/get.dart';
import 'package:store_app/models/tracking_history_model.dart';
import 'package:store_app/repositories/tracking_repository.dart';
import 'package:intl/intl.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/widgets/empty_tracking_state.dart';
import 'package:store_app/widgets/tracking_status_badge.dart';

/// Màn hình theo dõi đơn hàng
/// - Tải thông tin theo trackingId hoặc orderId
/// - Hiển thị Google Map (markers + polyline) và timeline lịch sử vận chuyển
class OrderTrackingScreen extends StatefulWidget {
  final String trackingId;
  final String? orderId; // Optional: can also load by orderId

  const OrderTrackingScreen({
    super.key,
    this.trackingId = '',
    this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  List<TrackingHistoryModel> _history = [];
  Map<String, dynamic>? _orderInfo;
  Map<String, dynamic>? _customer;
  bool _isLoading = true;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  /// Tải dữ liệu tracking từ server
  /// - Nếu có orderId: gọi getTrackingByOrderId
  /// - Ngược lại: gọi getTracking theo trackingId
  Future<void> _loadTracking() async {
    try {
      Map<String, dynamic> data;

      if (widget.orderId != null && widget.orderId!.isNotEmpty) {
        // Load by orderId
        data = await TrackingRepository.instance.getTrackingByOrderId(widget.orderId!);
        // Reconstruct orderInfo from available data
        _orderInfo = {
          'id': widget.orderId,
          'trackingId': data['trackingId'],
          'status': data['status'],
          'currentLocation': data['currentLocation'],
        };
        _history = data['history'] as List<TrackingHistoryModel>;
      } else {
        // Load by trackingId
        data = await TrackingRepository.instance.getTracking(widget.trackingId);
        _orderInfo = data['order'];
        _history = data['history'] as List<TrackingHistoryModel>;
        _customer = data['customer'];
      }

      setState(() => _isLoading = false);
      _buildMapData();
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Lỗi', 'Không thể tải thông tin: $e');
    }
  }

  /// Dựng dữ liệu bản đồ: marker cho từng điểm và polyline nối tuyến
  void _buildMapData() {
    if (_history.isEmpty) return;

    _markers.clear();
    _polylines.clear();

    // Add markers for each location
    for (int i = 0; i < _history.length; i++) {
      final h = _history[i];
      _markers.add(Marker(
        markerId: MarkerId(h.id),
        position: LatLng(h.latitude, h.longitude),
        infoWindow: InfoWindow(
          title: h.locationName,
          snippet: h.statusText,
        ),
        icon: i == _history.length - 1
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    // Add polyline connecting all points
    final points = _history.map((h) => LatLng(h.latitude, h.longitude)).toList();
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      color: Theme.of(context).primaryColor,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    ));

    setState(() {});

    // Animate camera to show all markers
    if (_mapController != null && _history.isNotEmpty) {
      _fitMapBounds();
    }
  }

  /// Đưa camera về khung nhìn bao trọn tất cả marker
  void _fitMapBounds() {
    if (_history.isEmpty || _mapController == null) return;

    double minLat = _history.first.latitude;
    double maxLat = _history.first.latitude;
    double minLng = _history.first.longitude;
    double maxLng = _history.first.longitude;

    for (var h in _history) {
      if (h.latitude < minLat) minLat = h.latitude;
      if (h.latitude > maxLat) maxLat = h.latitude;
      if (h.longitude < minLng) minLng = h.longitude;
      if (h.longitude > maxLng) maxLng = h.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theo dõi đơn hàng',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadTracking();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadTracking();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Order info card
                    if (_orderInfo != null) _buildOrderInfoCard(),

                    // Map view
                    if (_history.isNotEmpty) _buildMap(),

                    const SizedBox(height: 16),

                    // Timeline header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.timeline, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Lịch sử vận chuyển',
                            style: AppTextStyles.withColor(
                              AppTextStyles.h3,
                              isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Timeline
                    if (_history.isEmpty)
                      EmptyTrackingState(
                        message: 'Chưa có thông tin vận chuyển',
                        subtitle: 'Đơn hàng chưa được quét tại các điểm trung chuyển',
                        icon: Icons.location_off,
                      )
                    else
                      _buildTimeline(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderInfoCard() {
    final order = _orderInfo!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mã vận đơn: ${order['trackingId']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.info_outline,
              'Trạng thái',
              _getStatusText(order['status'] ?? 'pending'),
              _getStatusColor(order['status'] ?? 'pending'),
            ),
            if (order['currentLocation'] != null && order['currentLocation']['name'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on,
                'Vị trí hiện tại',
                order['currentLocation']['name'] ?? 'N/A',
                Theme.of(context).primaryColor,
              ),
            ],
            if (order['totalAmount'] != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.attach_money,
                'Tổng tiền',
                '\$${order['totalAmount'].toStringAsFixed(2)}',
                Colors.green,
              ),
            ],
            if (_customer != null) ...[
              const Divider(height: 24),
              Text(
                'Thông tin khách hàng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.person, 'Tên', _customer?['name'] ?? 'N/A', null),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.email, 'Email', _customer?['email'] ?? 'N/A', null),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color? valueColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_history.first.latitude, _history.first.longitude),
            zoom: 12,
          ),
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (controller) {
            _mapController = controller;
            _fitMapBounds();
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final isLast = index == _history.length - 1;
        final isFirst = index == 0;

        return TimelineTile(
          isFirst: isFirst,
          isLast: isLast,
          alignment: TimelineAlign.start,
          lineXY: 0.2,
          indicatorStyle: IndicatorStyle(
            width: 40,
            height: 40,
            indicator: Container(
              decoration: BoxDecoration(
                color: isLast ? Colors.green : Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isLast ? Colors.green : Theme.of(context).primaryColor)
                        .withAlpha((0.3 * 255).round()),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getStatusIcon(item.status),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          beforeLineStyle: LineStyle(
            color: isFirst
                ? Colors.transparent
                : (Theme.of(context).primaryColor.withAlpha((0.3 * 255).round())),
            thickness: 3,
          ),
          endChild: Card(
            margin: const EdgeInsets.only(left: 16, bottom: 16, top: 4),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.locationName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isLast)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Hiện tại',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TrackingStatusBadge(status: item.status),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'NV: ${item.scannedByName}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'picked_up':
        return Icons.inventory_2;
      case 'in_transit':
        return Icons.local_shipping;
      case 'arrived_hub':
        return Icons.warehouse;
      case 'out_for_delivery':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.location_on;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'picked_up':
        return Colors.blue;
      case 'in_transit':
        return Colors.orange;
      case 'arrived_hub':
        return Colors.purple;
      case 'out_for_delivery':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
