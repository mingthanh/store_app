import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/repositories/tracking_repository.dart';
import 'package:store_app/utils/app_textstyles.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);
    _controller.stop();

    final trackingId = barcode.rawValue!;

    try {
      // Show location selection dialog
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _ScanConfirmDialog(trackingId: trackingId),
      );

      if (result != null && mounted) {
        Get.snackbar(
          'Thành công',
          'Đã cập nhật vị trí đơn hàng',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _controller.start();
      }
    }
  }

  /// Xử lý nhập mã tracking thủ công
  /// Hiển thị dialog để người dùng nhập mã, sau đó mở dialog xác nhận location
  Future<void> _handleManualInput() async {
    final trackingId = await showDialog<String>(
      context: context,
      builder: (ctx) => _ManualInputDialog(),
    );

    if (trackingId != null && trackingId.isNotEmpty && mounted) {
      setState(() => _isProcessing = true);
      _controller.stop();

      try {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _ScanConfirmDialog(trackingId: trackingId),
        );

        if (result != null && mounted) {
          Get.snackbar(
            'Thành công',
            'Đã cập nhật vị trí đơn hàng',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể cập nhật: $e');
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
          _controller.start();
        }
      }
    }
  }

  /// Xử lý chọn ảnh QR code từ thư viện
  /// Hiện tại: Chức năng đang phát triển (mobile_scanner chưa hỗ trợ decode từ file)
  Future<void> _handleImagePicker() async {
    try {
      setState(() => _isProcessing = true);
      _controller.stop();

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        setState(() => _isProcessing = false);
        _controller.start();
        return;
      }

      // Note: mobile_scanner doesn't support image file scanning directly
      // For now, we'll show a message to use manual input or camera
      Get.snackbar(
        'Thông báo',
        'Chức năng quét QR từ ảnh đang được phát triển.\nVui lòng sử dụng camera hoặc nhập mã thủ công.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        _controller.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quét mã đơn hàng',
          style: AppTextStyles.withColor(
            AppTextStyles.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, child) {
                final isOn = value.torchState == TorchState.on;
                return Icon(isOn ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          // Scanning frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.7 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Đưa mã QR vào trong khung để quét',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // Alternative input buttons
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleImagePicker,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Tải ảnh'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleManualInput,
                    icon: const Icon(Icons.edit),
                    label: const Text('Nhập mã'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog to confirm location and status
class _ScanConfirmDialog extends StatefulWidget {
  final String trackingId;
  const _ScanConfirmDialog({required this.trackingId});

  @override
  State<_ScanConfirmDialog> createState() => _ScanConfirmDialogState();
}

class _ScanConfirmDialogState extends State<_ScanConfirmDialog> {
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedStatus = 'in_transit';
  bool _isLoading = false;
  Position? _currentPosition;

  final _statusOptions = {
    'picked_up': 'Đã lấy hàng',
    'in_transit': 'Đang vận chuyển',
    'arrived_hub': 'Đã tới trung tâm',
    'out_for_delivery': 'Đang giao hàng',
    'delivered': 'Đã giao hàng',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied) {
          Get.snackbar('Lỗi', 'Cần quyền truy cập vị trí');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không lấy được vị trí: $e');
    }
  }

  Future<void> _submit() async {
    if (_locationController.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập tên địa điểm');
      return;
    }

    if (_currentPosition == null) {
      Get.snackbar('Lỗi', 'Đang lấy vị trí GPS, vui lòng đợi...');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await TrackingRepository.instance.scanQR(
        trackingId: widget.trackingId,
        locationName: _locationController.text.trim(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop({'success': true});
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cập nhật vị trí đơn hàng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã: ${widget.trackingId}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Tên địa điểm *',
                hintText: 'VD: Kho Đà Nẵng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(),
              ),
              items: _statusOptions.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Đang lấy vị trí GPS...', style: TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Xác nhận'),
        ),
      ],
    );
  }
}

// Dialog for manual tracking ID input
class _ManualInputDialog extends StatefulWidget {
  @override
  State<_ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<_ManualInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidTrackingId(String id) {
    // Format: TRK + 13 digits + uppercase letters
    final regex = RegExp(r'^TRK\d{13}[A-Z]+$');
    return regex.hasMatch(id);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _controller.text = data!.text!.trim().toUpperCase();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim().toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nhập mã vận đơn'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nhập mã vận đơn để cập nhật vị trí',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Mã vận đơn',
                hintText: 'VD: TRK1762182472569EYHRJH',
                prefixIcon: const Icon(Icons.local_shipping),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  onPressed: _pasteFromClipboard,
                  tooltip: 'Dán',
                ),
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập mã vận đơn';
                }
                if (!_isValidTrackingId(value.trim().toUpperCase())) {
                  return 'Mã không hợp lệ (VD: TRK1762182472569EYHRJH)';
                }
                return null;
              },
              onChanged: (value) {
                // Auto uppercase
                final cursorPos = _controller.selection;
                _controller.value = TextEditingValue(
                  text: value.toUpperCase(),
                  selection: cursorPos,
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Format: TRK + 13 số + chữ in hoa',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Tiếp tục'),
        ),
      ],
    );
  }
}
