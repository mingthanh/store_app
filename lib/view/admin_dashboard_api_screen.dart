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
    _tabController = TabController(length: 3, vsync: this);
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
                  child: ListTile(
                    title: Text('Order ${o['_id']}'),
                    subtitle: Text('Total: ${o['totalAmount']} đ'),
                    trailing: _StatusDropdown(
                      value: o['status']?.toString() ?? 'pending',
                      onChanged: (val) => _changeOrderStatus(o, val),
                    ),
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

  Future<void> _load() async {
    // Tải thống kê + danh sách sản phẩm/đơn hàng/người dùng cho dashboard
    final t = auth.token.value;
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
      final t = auth.token.value!;
      final o = await OrderApiRepository.instance.allOrders(t);
      setState(() => orders = o.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> _loadUsers() async {
    // Chỉ refresh tab Users
    try {
      final t = auth.token.value!;
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
    final catCtrl = TextEditingController(text: existing?['category']?.toString() ?? 'Shoes');
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
                            final url = await UploadRepository.instance.uploadImageBytes(
                              auth.token.value!, bytes, file.name,
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
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
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
      'category': catCtrl.text.trim(),
      'description': descCtrl.text.trim(),
    };
    try {
      final t = auth.token.value!;
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
      final t = auth.token.value!;
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
      final t = auth.token.value!;
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
        final t = auth.token.value!;
        await UserRepository.instance.updateUser(t, user['_id'].toString(),
            name: nameCtrl.text.trim(), role: role);
        await _loadUsers();
      } catch (e) {
        Get.snackbar('Error', e.toString());
      }
    }
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