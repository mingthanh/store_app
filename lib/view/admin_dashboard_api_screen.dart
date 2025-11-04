import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_app/controllers/api_auth_controller.dart';
import 'package:store_app/repositories/admin_repository.dart';
import 'package:store_app/repositories/order_api_repository.dart';
import 'package:store_app/repositories/product_repository.dart';
import 'package:store_app/repositories/user_repository.dart';
import 'package:store_app/view/admin_account_screen.dart';
import 'package:store_app/view/signin_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:store_app/repositories/upload_repository.dart';
import 'package:store_app/view/qr_scanner_screen.dart';
import 'package:store_app/view/order_tracking_screen.dart';

class AdminDashboardApiScreen extends StatefulWidget {
  const AdminDashboardApiScreen({super.key});

  @override
  State<AdminDashboardApiScreen> createState() => _AdminDashboardApiScreenState();
}

class _AdminDashboardApiScreenState extends State<AdminDashboardApiScreen>
    with SingleTickerProviderStateMixin {
  final auth = Get.find<ApiAuthController>();
  Map<String, dynamic>? stats;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Changed from 3 to 4
    // Ensure FAB visibility updates when switching tabs
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Account',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Get.to(() => const AdminAccountScreen()),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout?'),
                  content: const Text('You will be signed out of the admin site.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
                  ],
                ),
              );
              if (ok == true) {
                auth.signOut();
                Get.offAll(() => SigninScreen());
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Orders'),
            Tab(text: 'Users'),
            Tab(text: 'Tracking'), // NEW TAB
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0 && auth.isAdmin
          ? FloatingActionButton(
              onPressed: () => _addOrEdit(), child: const Icon(Icons.add))
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _productsTab(),
                _ordersTab(),
                _usersTab(),
                _trackingTab(), // NEW TAB CONTENT
              ],
            ),
    );
  }

  Widget _productsTab() => RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (stats != null) _Stats(stats: stats!),
            const SizedBox(height: 12),
            const Text('Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...products.map((p) => Card(
                  child: ListTile(
                    leading: (p['imageUrl']?.toString().isNotEmpty ?? false)
                        ? Image.network(p['imageUrl'],
                            width: 48, height: 48, fit: BoxFit.cover)
                        : const Icon(Icons.image),
                    title: Text(p['name']?.toString() ?? ''),
                    subtitle: Text('${p['price']} đ'),
                    trailing: auth.isAdmin
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () => _addOrEdit(existing: p),
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () => _delete(p),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red)),
                            ],
                          )
                        : null,
                  ),
                )),
          ],
        ),
      );

  Widget _ordersTab() => RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text('Orders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...orders.map((o) => Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Order ${o['_id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total: ${o['totalAmount']} đ'),
                            if (o['trackingId'] != null)
                              Text(
                                'Tracking: ${o['trackingId']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        trailing: _StatusDropdown(
                          value: o['status']?.toString() ?? 'pending',
                          onChanged: (val) => _changeOrderStatus(o, val),
                        ),
                      ),
                      // ACTION BUTTONS ROW
                      if (o['trackingId'] != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _scanQRForOrder(o),
                                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                                  label: const Text('Scan QR'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _viewTracking(o['trackingId']),
                                  icon: const Icon(Icons.location_on, size: 18),
                                  label: const Text('View Tracking'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                )),
          ],
        ),
      );

  Widget _usersTab() => RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Text('Users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...users.map((u) => Card(
                  child: ListTile(
                    title: Text(u['name']?.toString() ?? ''),
                    subtitle: Text('${u['email']} • role: ${u['role']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editUser(u),
                    ),
                  ),
                )),
          ],
        ),
      );

  /// Safely get token, show error if not available
  String? _getTokenSafely() {
    final token = auth.token.value;
    if (token == null || token.isEmpty) {
      if (auth.isSocialLogin.value) {
        Get.snackbar(
          'Admin Access Limited',
          'Some admin features require email/password login. Please create an admin account with email and password.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar('Authentication Error', 'Please sign in again');
      }
      return null;
    }
    return token;
  }

  Future<void> _load() async {
    // Tải thống kê + danh sách sản phẩm/đơn hàng/người dùng cho dashboard
    final t = _getTokenSafely();
    if (t == null || !auth.isAdmin) {
      Get.snackbar('Access denied', 'Admin only');
      Get.back();
      return;
    }
    try {
      final s = await AdminRepository.instance.getStats(t);
      final p = await ProductRepository.instance.fetchProducts(limit: 200);
      final o = await OrderApiRepository.instance.allOrders(t);
      final u = await UserRepository.instance.fetchUsers(t);
      setState(() {
        stats = s;
        products = p;
        orders = o.cast<Map<String, dynamic>>();
        users = u.cast<Map<String, dynamic>>();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadOrders() async {
    // Chỉ refresh tab Orders để giảm tải
    try {
      final t = _getTokenSafely();
      if (t == null) return;
      final o = await OrderApiRepository.instance.allOrders(t);
      setState(() => orders = o.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadUsers() async {
    // Chỉ refresh tab Users
    try {
      final t = _getTokenSafely();
      if (t == null) return;
      final u = await UserRepository.instance.fetchUsers(t);
      setState(() => users = u.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _addOrEdit({Map<String, dynamic>? existing}) async {
    // Dialog thêm/sửa sản phẩm. Nếu existing != null thì là chế độ sửa
    final nameCtrl = TextEditingController(text: existing?['name']?.toString());
    final priceCtrl = TextEditingController(text: existing?['price']?.toString());
    final imgCtrl = TextEditingController(text: existing?['imageUrl']?.toString());
    final catCtrl = TextEditingController(text: existing?['category']?.toString() ?? 'Men');
    // Multi-category support: Men/Women/Girls
    final options = const ['Men','Women','Girls'];
    final Set<String> selectedCats = {
      ...((existing?['categories'] is List)
          ? (existing!['categories'] as List).map((e) => e.toString())
          : <String>[]),
    };
    if (selectedCats.isEmpty && (existing?['category'] is String)) {
      selectedCats.add(existing!['category'].toString());
    }
    final descCtrl = TextEditingController(text: existing?['description']?.toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
        title: Text(existing == null ? 'Add Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (VND)'), keyboardType: TextInputType.number),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Image URL'))),
                  const SizedBox(width: 8),
                  // Nút Upload ảnh: mở file picker, gửi multipart tới server, tự điền URL vào ô Image URL
                  OutlinedButton.icon(
                    onPressed: () async {
                      setStateDialog((){});
                      try {
                        final res = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (res != null && res.files.isNotEmpty) {
                          final file = res.files.single;
                          final bytes = file.bytes;
                          if (bytes != null) {
                            final token = _getTokenSafely();
                            if (token == null) return;
                            final url = await UploadRepository.instance.uploadImageBytes(
                              token, bytes, file.name,
                            );
                            imgCtrl.text = url;
                          }
                        }
                      } catch (e) {
                        Get.snackbar('Upload failed', e.toString());
                      } finally {
                        setStateDialog((){});
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Categories', style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((c) => FilterChip(
                  label: Text(c),
                  selected: selectedCats.contains(c),
                  onSelected: (sel) {
                    setStateDialog(() {
                      if (sel) {
                        selectedCats.add(c);
                      } else {
                        selectedCats.remove(c);
                      }
                      // Keep a primary category text (first selected) for backward compat
                      catCtrl.text = selectedCats.isEmpty ? '' : selectedCats.first;
                    });
                  },
                )).toList(),
              ),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      );
        }
      ),
    );
    if (ok != true) return;

    final body = {
      'name': nameCtrl.text.trim(),
      'price': int.tryParse(priceCtrl.text.trim()) ?? 0,
      'imageUrl': imgCtrl.text.trim(),
      'category': (selectedCats.isNotEmpty ? selectedCats.first : 'Men'),
      'categories': selectedCats.toList(),
      'description': descCtrl.text.trim(),
    };
    try {
      final t = _getTokenSafely();
      if (t == null) return;
      if (existing == null) {
        await AdminRepository.instance.createProduct(t, body); // Tạo mới
      } else {
        await AdminRepository.instance
            .updateProduct(t, existing['_id']?.toString() ?? '', body);
      }
      await _load();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _delete(Map<String, dynamic> product) async {
    // Xoá sản phẩm sau khi xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(product['name']?.toString() ?? ''),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final t = _getTokenSafely();
      if (t == null) return;
      await AdminRepository.instance
          .deleteProduct(t, product['_id']?.toString() ?? '');
      await _load();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _changeOrderStatus(
      Map<String, dynamic> order, String status) async {
    // Admin đổi trạng thái đơn rồi refresh danh sách
    try {
      final t = _getTokenSafely();
      if (t == null) return;
      await OrderApiRepository.instance
          .updateStatus(t, order['_id'].toString(), status);
      await _loadOrders();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _editUser(Map<String, dynamic> user) async {
    final nameCtrl = TextEditingController(text: user['name']?.toString());
    int role = (user['role'] as num?)?.toInt() ?? 1;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: role,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Admin')),
                DropdownMenuItem(value: 1, child: Text('User')),
              ],
              onChanged: (v) => role = v ?? role,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      try {
        final t = _getTokenSafely();
        if (t == null) return;
        await UserRepository.instance.updateUser(t, user['_id'].toString(),
            name: nameCtrl.text.trim(), role: role);
        await _loadUsers();
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
  }

  // ==================== TRACKING FEATURES ====================
  // Các tính năng quản lý tracking đơn hàng cho admin

  /// Tab Tracking - Hiển thị tất cả đơn hàng có tracking ID
  /// Cho phép admin:
  /// - Xem danh sách đơn hàng đang được tracking
  /// - Quét QR code nhanh
  /// - Xem vị trí hiện tại của đơn hàng
  /// - Click vào đơn hàng để xem trên bản đồ
  Widget _trackingTab() => RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openQRScanner(),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Filter only orders with trackingId
            ...orders
                .where((o) => o['trackingId'] != null)
                .map((o) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping,
                            color: Colors.blue),
                        title: Text(
                          o['trackingId']?.toString() ?? '',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order: ${o['_id']}'),
                            Text('Total: ${o['totalAmount']} đ'),
                            Text('Status: ${o['status']}'),
                            if (o['currentLocation'] != null &&
                                o['currentLocation']['name'] != null)
                              Text(
                                '📍 ${o['currentLocation']['name']}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.map),
                          color: Colors.green,
                          onPressed: () => _viewTracking(o['trackingId']),
                          tooltip: 'View on Map',
                        ),
                        onTap: () => _viewTracking(o['trackingId']),
                      ),
                    )),
            if (orders.where((o) => o['trackingId'] != null).isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.location_off,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No tracked orders yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );

  /// Mở màn hình quét QR code
  /// Sau khi quét xong và cập nhật thành công, reload danh sách đơn hàng
  void _openQRScanner() async {
    final result = await Get.to(() => const QrScannerScreen());
    if (result == true) {
      _loadOrders(); // Refresh danh sách sau khi quét
    }
  }

  /// Quét QR code cho đơn hàng cụ thể
  /// Hiển thị dialog xác nhận trước khi mở camera
  /// Sau khi quét xong, cập nhật danh sách đơn hàng
  void _scanQRForOrder(Map<String, dynamic> order) async {
    final trackingId = order['trackingId']?.toString();
    if (trackingId == null) {
      Get.snackbar('Error', 'This order has no tracking ID');
      return;
    }

    // Hiển thị thông tin đơn hàng sẽ được quét
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You will scan QR code for:'),
            const SizedBox(height: 8),
            Text(
              'Order: ${order['_id']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Tracking ID: $trackingId'),
            Text('Total: ${order['totalAmount']} đ'),
            const SizedBox(height: 16),
            const Text(
              'Make sure you scan the correct QR code!',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Open Scanner'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await Get.to(() => const QrScannerScreen());
      if (result == true) {
        _loadOrders(); // Refresh after scanning
        Get.snackbar(
          'Success',
          'Location updated for order ${order['_id']}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }
  }

  /// Xem tracking trên bản đồ
  /// Mở màn hình OrderTrackingScreen với tracking ID
  /// Hiển thị lịch sử vận chuyển và vị trí trên Google Maps
  void _viewTracking(String? trackingId) {
    if (trackingId == null || trackingId.isEmpty) {
      Get.snackbar('Error', 'Invalid tracking ID');
      return;
    }

    Get.to(() => OrderTrackingScreen(trackingId: trackingId));
  }
}

class _Stats extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _Stats({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _tile('Users', stats['users']?.toString() ?? '0'),
            _tile('Products', stats['products']?.toString() ?? '0'),
            _tile('Orders', stats['orders']?.toString() ?? '0'),
            _tile('Revenue', '${stats['revenue'] ?? 0} đ'),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      );
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const statuses = [
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled'
    ];
    return DropdownButton<String>(
      value: statuses.contains(value) ? value : 'pending',
      underline: const SizedBox.shrink(),
      items: statuses
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}