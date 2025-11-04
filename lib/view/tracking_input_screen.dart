import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_app/view/order_tracking_screen.dart';

/// Màn hình nhập mã tracking thủ công hoặc từ ảnh QR
/// Cho phép người dùng tra cứu đơn hàng bằng 3 cách:
/// 1. Nhập mã tracking thủ công
/// 2. Quét QR bằng camera
/// 3. Tải ảnh QR từ thư viện (đang phát triển)
class TrackingInputScreen extends StatefulWidget {
  const TrackingInputScreen({super.key});

  @override
  State<TrackingInputScreen> createState() => _TrackingInputScreenState();
}

class _TrackingInputScreenState extends State<TrackingInputScreen> {
  final TextEditingController _trackingIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  void dispose() {
    _trackingIdController.dispose();
    super.dispose();
  }

  /// Kiểm tra format mã tracking hợp lệ
  /// Format: TRK + 13 chữ số + chữ cái in hoa
  /// VD: TRK1762182472569EYHRJH
  bool _isValidTrackingId(String id) {
    final regex = RegExp(r'^TRK\d{13}[A-Z]+$');
    return regex.hasMatch(id);
  }

  /// Xử lý khi submit form nhập mã thủ công
  void _submitManualInput() {
    if (_formKey.currentState!.validate()) {
      final trackingId = _trackingIdController.text.trim();
      Get.off(() => OrderTrackingScreen(trackingId: trackingId));
    }
  }

  /// Chọn ảnh từ thư viện và quét QR code
  /// Hiện tại: Chức năng đang phát triển
  /// TODO: Implement QR decoding từ file ảnh (cần package qr_code_tools)
  Future<void> _pickImageAndScan() async {
    setState(() => _isProcessing = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        setState(() => _isProcessing = false);
        return;
      }

      // Thông báo đang xử lý
      Get.snackbar(
        'Thông báo',
        'Đang xử lý ảnh QR...',
        duration: const Duration(seconds: 2),
      );

      // Hiện tại mobile_scanner chưa hỗ trợ decode QR từ file ảnh
      // Cần dùng package khác như qr_code_tools
      Get.snackbar(
        'Lỗi',
        'Chức năng quét QR từ ảnh đang được phát triển.\nVui lòng sử dụng camera để quét QR hoặc nhập mã thủ công.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );

    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xử lý ảnh: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Dán mã tracking từ clipboard
  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _trackingIdController.text = data!.text!.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tra cứu vận đơn'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header icon
              Icon(
                Icons.search,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Nhập mã vận đơn',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập mã vận đơn hoặc tải ảnh QR code để tra cứu',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Manual input field
              TextFormField(
                controller: _trackingIdController,
                decoration: InputDecoration(
                  labelText: 'Mã vận đơn',
                  hintText: 'VD: TRK1762182472569EYHRJH',
                  prefixIcon: const Icon(Icons.local_shipping),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.content_paste),
                    tooltip: 'Dán từ clipboard',
                    onPressed: _pasteFromClipboard,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã vận đơn';
                  }
                  if (!_isValidTrackingId(value.trim())) {
                    return 'Mã vận đơn không hợp lệ (VD: TRK1762182472569EYHRJH)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Submit button
              ElevatedButton.icon(
                onPressed: _submitManualInput,
                icon: const Icon(Icons.search),
                label: const Text('Tra cứu'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              // Divider with text
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'HOẶC',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 32),

              // Alternative methods
              _buildAlternativeMethod(
                icon: Icons.qr_code_scanner,
                title: 'Quét QR bằng camera',
                subtitle: 'Mở camera và quét mã QR trên vận đơn',
                color: Colors.blue,
                onTap: () {
                  Get.back(); // Go back to use QR scanner
                },
              ),

              const SizedBox(height: 16),

              _buildAlternativeMethod(
                icon: Icons.photo_library,
                title: 'Tải ảnh QR từ máy',
                subtitle: 'Chọn ảnh QR code từ thư viện ảnh',
                color: Colors.green,
                onTap: _isProcessing ? null : _pickImageAndScan,
                isLoading: _isProcessing,
              ),

              const SizedBox(height: 24),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.blue[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Mã vận đơn có định dạng: TRK + 13 số + chữ cái in hoa\n'
                      '• Bạn có thể tìm mã trên email xác nhận đơn hàng\n'
                      '• Hoặc quét QR code trên phiếu giao hàng',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternativeMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
