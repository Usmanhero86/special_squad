import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/payment.dart';
import '../models/payment_member.dart';

class PaymentService {
  final ApiClient api;

  PaymentService({required this.api});

  /// ==============================
  /// GET PAYMENT MEMBERS
  /// ==============================
  Future<List<PaymentMember>> getPaymentMembers({
    int page = 1,
    int limit = 100,
    String? month,
  }) async {
    final now = DateTime.now();
    final monthParam = month ?? '${now.month},${now.year}';

    final path =
        '/api/v1/admin/payment/members?page=$page&limit=$limit&month=$monthParam';

    debugPrint('🟡 FETCHING PAYMENT MEMBERS');
    debugPrint('📍 PATH: $path');

    final response = await api.get(path);

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch payment members',
      );
    }

    final List list = data['responseBody']['data'] ?? [];
    return list.map((e) => PaymentMember.fromJson(e)).toList();
  }

  /// ==============================
  /// GET RECENT PAYMENTS
  /// ==============================
  Future<List<Payment>> getRecentPayments({
    int page = 1,
    int limit = 100,
    String? month,
  }) async {
    final now = DateTime.now();
    final monthParam = month ?? '${now.month},${now.year}';

    final path =
        '/api/v1/admin/payment/members?page=$page&limit=$limit&month=$monthParam';

    debugPrint('🟡 FETCHING PAYMENTS');
    debugPrint('📍 PATH: $path');

    final response = await api.get(path);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch payments',
      );
    }

    final List list = data['responseBody']['data'] ?? [];
    return list.map((e) => Payment.fromJson(e)).toList();
  }

  /// ==============================
  /// ADD PAYMENT
  /// ==============================
  Future<void> addPayment(Payment payment, Object? object) async {
    debugPrint('🟡 ADDING PAYMENT');

    final response = await api.post(
      '/api/v1/admin/payment/pay',
      body: {
        'memberId': payment.memberId,
        'amount': payment.amount,
        'purpose': payment.purpose,
        'paymentMethod': payment.paymentMethod,
        'note': payment.notes ?? '',
        'forMonth': payment.paymentDate.toIso8601String(),
      },
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if ((response.statusCode != 200 &&
        response.statusCode != 201) ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to add payment',
      );
    }
  }

  /// ==============================
  /// UPDATE PAYMENT
  /// ==============================
  Future<void> updatePayment(Payment payment) async {
    debugPrint('🟡 UPDATING PAYMENT: ${payment.id}');

    final response = await api.post(
      '/api/v1/admin/payment/${payment.id}',
      body: {
        'paymentStatus': payment.status,
        'amount': payment.amount,
        'paymentMethod': payment.paymentMethod,
        'description': payment.notes,
      },
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(
        data['responseMessage'] ?? 'Failed to update payment',
      );
    }
  }
}