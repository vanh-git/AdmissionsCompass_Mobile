import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class CreditPackage {
  final String id;
  final String name;
  final int credits;
  final int priceVnd;

  const CreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.priceVnd,
  });
}

class PaymentOrder {
  final int orderCode;
  final String qrCode;
  final String checkoutUrl;
  final int amount;
  final int credits;

  const PaymentOrder({
    required this.orderCode,
    required this.qrCode,
    required this.checkoutUrl,
    required this.amount,
    required this.credits,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      orderCode: (json['orderCode'] as num).toInt(),
      qrCode: json['qrCode'] as String,
      checkoutUrl: json['checkoutUrl'] as String,
      amount: (json['amount'] as num).toInt(),
      credits: (json['credits'] as num).toInt(),
    );
  }
}

class NumerologyCreditService {
  final FirebaseFirestore firestore;
  final String apiBaseUrl;

  NumerologyCreditService({
    FirebaseFirestore? firestore,
    this.apiBaseUrl = const String.fromEnvironment(
      'PAYOS_API_BASE_URL',
      defaultValue: 'https://labantuyensinh.vercel.app',
    ),
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  static const packages = [
    CreditPackage(
      id: 'starter',
      name: 'Bản đồ linh hồn',
      credits: 3,
      priceVnd: 15000,
    ),
    CreditPackage(
      id: 'popular',
      name: 'Hành trình khám phá',
      credits: 10,
      priceVnd: 49000,
    ),
    CreditPackage(
      id: 'premium',
      name: 'Gói đồng hành',
      credits: 30,
      priceVnd: 129000,
    ),
  ];

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      firestore.collection('users').doc(uid);

  Stream<int> watchCredits(String uid) => _user(uid).snapshots().map(
    (snapshot) => (snapshot.data()?['credits'] as num?)?.toInt() ?? 0,
  );

  Future<int> getCredits(String uid) async =>
      ((await _user(uid).get()).data()?['credits'] as num?)?.toInt() ?? 0;

  Future<bool> consumeCredit(String uid) async {
    return firestore.runTransaction((transaction) async {
      final reference = _user(uid);
      final snapshot = await transaction.get(reference);
      final credits = (snapshot.data()?['credits'] as num?)?.toInt() ?? 0;
      if (credits < 1) return false;
      transaction.set(reference, {
        'credits': credits - 1,
        'lastNumerologyViewAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    });
  }

  Future<PaymentOrder> createPayment({
    required String uid,
    required CreditPackage package,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/pc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid, 'packageId': package.id}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['error'] != null) {
      throw StateError(body['error'] as String? ?? 'Không thể tạo thanh toán.');
    }
    final order = PaymentOrder.fromJson(body);
    return order;
  }

  Stream<String> watchPaymentStatus(int orderCode) => firestore
      .collection('payment_orders')
      .doc(orderCode.toString())
      .snapshots()
      .map((snapshot) => snapshot.data()?['status'] as String? ?? 'PENDING');
}
