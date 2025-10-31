import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> userWishlist(String userId) =>
      users.doc(userId).collection('wishlist');
  CollectionReference<Map<String, dynamic>> userCart(String userId) =>
      users.doc(userId).collection('cart');
  CollectionReference<Map<String, dynamic>> get products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get orders =>
    _db.collection('orders');

  // User
  Future<void> upsertUserProfile({
    required String userId,
    required String name,
    required String email,
    String? photoUrl,
    Map<String, dynamic>? extra,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
      ...?extra,
    };
    await users.doc(userId).set(data, SetOptions(merge: true));
    debugPrint('[Firestore] upsertUserProfile ok: userId=$userId');
  }

  // Orders
  Future<String> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required int totalAmount,
    String status = 'processing',
  }) async {
    final doc = await orders.add({
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[Firestore] createOrder ok: id=${doc.id}');
    return doc.id;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await orders.doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[Firestore] updateOrderStatus ok: id=$orderId status=$status');
  }

  Stream<List<Map<String, dynamic>>> ordersStream({String? status}) {
    Query<Map<String, dynamic>> q = orders.orderBy('createdAt', descending: true);
    if (status != null) {
      q = q.where('status', isEqualTo: status);
    }
    return q.snapshots().map(
          (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<Map<String, num>> ordersSummary() async {
    final snap = await orders.get();
    int count = snap.docs.length;
    int revenue = 0;
    final byStatus = <String, int>{};
    for (final d in snap.docs) {
      final m = d.data();
      revenue += (m['totalAmount'] as num?)?.toInt() ?? 0;
      final st = (m['status'] as String?) ?? 'processing';
      byStatus[st] = (byStatus[st] ?? 0) + 1;
    }
    return {
      'count': count,
      'revenue': revenue,
      ...byStatus.map((k, v) => MapEntry('status_$k', v)),
    };
  }

  // Wishlist
  Future<void> setWishlistItem({
    required String userId,
    required String productId,
    required bool wished,
  }) async {
    final ref = userWishlist(userId).doc(productId);
    if (wished) {
      await ref.set({'addedAt': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }

  Stream<Set<String>> wishlistIdsStream(String userId) {
    return userWishlist(userId).snapshots().map((snap) {
      return snap.docs.map((d) => d.id).toSet();
    });
  }

  // Cart
  Future<void> addOrUpdateCartItem({
    required String userId,
    required String productId,
    required int quantity,
    Map<String, dynamic>? meta,
  }) async {
    final ref = userCart(userId).doc(productId);
    if (quantity <= 0) {
      await ref.delete();
      return;
    }
    await ref.set({
      'quantity': quantity,
      if (meta != null) 'meta': meta,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, int>> cartStream(String userId) {
    return userCart(userId).snapshots().map((snap) {
      final map = <String, int>{};
      for (final d in snap.docs) {
        final q = (d.data()['quantity'] as num?)?.toInt() ?? 0;
        if (q > 0) map[d.id] = q;
      }
      return map;
    });
  }

  // ===== Products (sample seeding for development) =====
  Future<bool> _hasAnyProducts() async {
    final snap = await products.limit(1).get();
    return snap.docs.isNotEmpty;
  }

  Future<int> seedSampleProductsIfEmpty() async {
    if (await _hasAnyProducts()) {
      debugPrint('[Firestore] products already exist, skip seeding');
      return 0;
    }

    final now = FieldValue.serverTimestamp();
    final data = <Map<String, dynamic>>[
      {
        'id': 'prd_shoe_airmax_white',
        'name': 'Air Max White',
        'price': 1990000,
        'imageUrl': 'https://picsum.photos/seed/airmax_white/600/600',
        'category': 'Shoes',
        'description': 'Giày Air Max màu trắng, êm ái, phù hợp đi hàng ngày.',
        'stock': 50,
        'createdAt': now,
      },
      {
        'id': 'prd_shoe_airmax_black',
        'name': 'Air Max Black',
        'price': 2050000,
        'imageUrl': 'https://picsum.photos/seed/airmax_black/600/600',
        'category': 'Shoes',
        'description': 'Air Max màu đen, dễ phối đồ, đệm khí êm chân.',
        'stock': 40,
        'createdAt': now,
      },
      {
        'id': 'prd_shoe_jordan_mid',
        'name': 'Jordan 1 Mid',
        'price': 3290000,
        'imageUrl': 'https://picsum.photos/seed/jordan_mid/600/600',
        'category': 'Shoes',
        'description': 'Jordan 1 Mid phong cách, nổi bật trên từng bước chân.',
        'stock': 25,
        'createdAt': now,
      },
      {
        'id': 'prd_shoe_ultra_run',
        'name': 'Ultra Run Pro',
        'price': 2590000,
        'imageUrl': 'https://picsum.photos/seed/ultra_run/600/600',
        'category': 'Shoes',
        'description': 'Giày chạy bộ nhẹ, thoáng khí, hỗ trợ tốt khi vận động.',
        'stock': 35,
        'createdAt': now,
      },
      {
        'id': 'prd_shoe_canvas_low',
        'name': 'Canvas Low',
        'price': 890000,
        'imageUrl': 'https://picsum.photos/seed/canvas_low/600/600',
        'category': 'Shoes',
        'description': 'Giày vải thấp cổ, trẻ trung, năng động.',
        'stock': 60,
        'createdAt': now,
      },
      {
        'id': 'prd_shoe_hiker_pro',
        'name': 'Hiker Pro',
        'price': 2790000,
        'imageUrl': 'https://picsum.photos/seed/hiker_pro/600/600',
        'category': 'Shoes',
        'description': 'Giày leo núi bền bỉ, bám tốt, chống trơn trượt.',
        'stock': 20,
        'createdAt': now,
      },
    ];

    final batch = _db.batch();
    for (final p in data) {
      final docId = p['id'] as String;
      batch.set(products.doc(docId), p, SetOptions(merge: true));
    }
    await batch.commit();
    debugPrint('[Firestore] Seeded ${data.length} sample products');
    return data.length;
  }

  // ===== Products: CRUD helpers =====
  Future<void> addOrUpdateProduct({
    required String id,
    required String name,
    required int price,
    String? imageUrl,
    String? category,
    String? description,
    int? stock,
    Map<String, dynamic>? extra,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'price': price,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (stock != null) 'stock': stock,
      'updatedAt': FieldValue.serverTimestamp(),
      ...?extra,
    };
    await products.doc(id).set(data, SetOptions(merge: true));
    debugPrint('[Firestore] addOrUpdateProduct ok: id=$id');
  }

  Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
    debugPrint('[Firestore] deleteProduct ok: id=$id');
  }

  Stream<List<Map<String, dynamic>>> productsStream({
    String? category,
    int limit = 50,
  }) {
    Query<Map<String, dynamic>> q = products.orderBy('name');
    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }
    q = q.limit(limit);
    return q.snapshots().map(
      (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    );
  }
}
