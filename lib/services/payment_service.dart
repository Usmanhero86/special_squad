import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/payment.dart';
import '../models/payment_detail.dart';
import '../models/payment_member.dart';
import '../models/payment_response.dart';

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

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch payment members',
      );
    }

    final List list = data['responseBody']['data'] ?? [];
    return list.map((e) => PaymentMember.fromJson(e)).toList();
  }

  /// ==============================
  /// GET ALL PAYMENTS
  /// ==============================
  Future<List<Payment>> getAllPayments({int page = 1, int limit = 100}) async {
    final path = '/api/v1/admin/payment?page=$page&limit=$limit';

    debugPrint('🟡 FETCHING PAYMENTS');
    debugPrint('📍 PATH: $path');

    final response = await api.get(path);

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to fetch payments');
    }

    final List list = data['responseBody']['data'] ?? [];
    return list.map((e) => Payment.fromJson(e)).toList();
  }

  /// ==============================
  /// GET PAYMENTS (PAGINATED)
  /// ==============================
  Future<PaymentPagedResponse> getPayments({
    int page = 1,
    int limit = 10,
    String? month,
    String? year,
  }) async {
    debugPrint('🟡 FETCHING PAYMENTS');

    // Build query parameters
    final queryParams = <String>['page=$page', 'limit=$limit'];

    if (month != null && year != null) {
      queryParams.add('month=$month,$year');
      debugPrint('📅 FILTERING BY: $month $year');
    }

    final queryString = queryParams.join('&');
    final endpoint = '/api/v1/admin/payment?$queryString';

    debugPrint('📍 ENDPOINT: $endpoint');

    final response = await api.get(endpoint);

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage']);
    }

    return PaymentPagedResponse.fromJson(data);
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

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to fetch payments');
    }

    final List list = data['responseBody']['data'] ?? [];
    return list.map((e) => Payment.fromJson(e)).toList();
  }

  /// ==============================
  /// GET PAYMENT BY ID
  /// ==============================
  Future<PaymentDetail> getPaymentById(String paymentId) async {
    debugPrint('🟡 FETCHING PAYMENT BY ID: $paymentId');

    final response = await api.get('/api/v1/admin/payment/$paymentId');

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch payment details',
      );
    }

    return PaymentDetail.fromJson(data['responseBody']);
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

    if ((response.statusCode != 200 && response.statusCode != 201) ||
        data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to add payment');
    }
  }

  /// ==============================
  /// MAKE PAYMENT
  /// ==============================
  Future<void> makePayment({
    required String memberId,
    required double amount,
    required String purpose,
    required String paymentMethod,
    String? note,
    required String forMonth,
  }) async {
    final payload = {
      'memberId': memberId,
      'amount': amount,
      'purpose': purpose,
      'paymentMethod': paymentMethod.toUpperCase(),
      'note': note ?? '',
      'forMonth': forMonth,
    };

    debugPrint('📤 PAYMENT PAYLOAD: $payload');

    final response = await api.post('/api/v1/admin/payment/pay', body: payload);

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = data['responseMessage']?.toString() ?? '';

      // 🔥 HANDLE DB NUMERIC OVERFLOW (12 BILLION ISSUE)
      if (message.contains('numeric field overflow') ||
          message.contains('precision 10') ||
          message.contains('10^8')) {
        throw Exception(
          'Amount exceeds allowed limit. Maximum allowed is ₦99,999,999.99',
        );
      }

      throw Exception(message.isNotEmpty ? message : 'Payment failed');
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

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['responseMessage'] ?? 'Failed to update payment');
    }
  }

  /// ==============================
  /// UPDATE PAYMENT STATUS
  /// ==============================
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    debugPrint('🟡 UPDATING PAYMENT STATUS: $paymentId');
    debugPrint('📤 NEW STATUS: $status');

    final response = await api.post(
      '/api/v1/admin/payment/$paymentId',
      body: {'paymentStatus': status},
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to update payment status',
      );
    }

    if (data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to update payment status',
      );
    }
  }

  /// ==============================
  /// DELETE PAYMENT
  /// ==============================
  Future<void> deletePayment(String paymentId) async {
    debugPrint('🟡 DELETING PAYMENT: $paymentId');

    final response = await api.delete('/api/v1/admin/payment/$paymentId');

    debugPrint('📥 DELETE STATUS: ${response.statusCode}');
    debugPrint('📥 DELETE BODY: ${response.body}');

    // Handle HTML error responses (like 404 pages)
    if (response.body.trim().startsWith('<!DOCTYPE html>') ||
        response.body.trim().startsWith('<html')) {
      debugPrint('🔥 Server returned HTML error page instead of JSON');
      debugPrint(
        '🔥 This usually means the endpoint does not exist or method is not allowed',
      );
      throw Exception(
        'Delete payment endpoint not found. The backend may not support payment deletion yet. Please contact the backend team to implement: DELETE /api/v1/admin/payment/{paymentId}',
      );
    }

    // Some APIs return 204 No Content for successful deletion
    if (response.statusCode == 204) {
      debugPrint('✅ Payment deleted successfully (204 No Content)');
      return;
    }

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['responseMessage'] ?? 'Failed to delete payment');
    }

    if (data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Delete request failed');
    }

    debugPrint('✅ Payment deleted successfully');
  }
}
