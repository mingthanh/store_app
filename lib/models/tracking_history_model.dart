/// Mô hình một bản ghi lịch sử vận chuyển (tracking history)
/// Gắn với một đơn hàng, lưu vị trí, thời điểm và trạng thái
class TrackingHistoryModel {
  final String id;
  final String orderId;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String scannedBy;
  final String scannedByName;
  final String status;
  final String? notes;

  TrackingHistoryModel({
    required this.id,
    required this.orderId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.scannedBy,
    required this.scannedByName,
    required this.status,
    this.notes,
  });

  /// Parse JSON trả về từ API → TrackingHistoryModel
  factory TrackingHistoryModel.fromJson(Map<String, dynamic> json) {
    return TrackingHistoryModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      locationName: json['locationName'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      scannedBy: json['scannedBy']?['_id'] ?? json['scannedBy'] ?? '',
      scannedByName: json['scannedBy']?['name'] ?? 'Unknown',
      status: json['status'] ?? '',
      notes: json['notes'],
    );
  }

  /// Chuỗi trạng thái hiển thị tiếng Việt
  String get statusText {
    switch (status) {
      case 'picked_up':
        return 'Đã lấy hàng';
      case 'in_transit':
        return 'Đang vận chuyển';
      case 'arrived_hub':
        return 'Đã tới trung tâm';
      case 'out_for_delivery':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      default:
        return status;
    }
  }

  /// Chuỗi trạng thái hiển thị tiếng Anh
  String get statusTextEn {
    switch (status) {
      case 'picked_up':
        return 'Picked Up';
      case 'in_transit':
        return 'In Transit';
      case 'arrived_hub':
        return 'Arrived at Hub';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }
}
