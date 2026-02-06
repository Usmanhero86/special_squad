import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../core/api_client.dart';
import '../models/payment.dart';
import '../models/paymentListMembers.dart';
import '../models/payment_detail.dart';
import '../models/payment_response.dart';
import 'database_helper.dart';

class PaymentServices {
  final ApiClient api;

  PaymentServices({required this.api});

  /// ==============================
  /// GET ALL PAYMENTS
  /// ==============================
  Future<List<Payment>> getAllPayments({
    int page = 1,
    int limit = 100,
  }) async {
    final path =
        '/api/v1/admin/payment?page=$page&limit=$limit';

    debugPrint('🟡 FETCHING PAYMENTS');
    debugPrint('📍 PATH: $path');

    final response = await api.get(path);

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

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
  /// GET PAYMENT MEMBERS
  /// ==============================
  Future<PaymentPagedResponse> getPayments({
    int page = 1,
    int limit = 10,
  }) async {
    debugPrint('🟡 FETCHING PAYMENTS');

    final response = await api.get(
      '/api/v1/admin/payment?page=$page&limit=$limit',
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage']);
    }

    return PaymentPagedResponse.fromJson(data);
  }
  /// ==============================
  /// GET PAYMENT BY ID
  /// ==============================
  Future<PaymentDetail> getPaymentById(String paymentId) async {
    debugPrint('🟡 FETCHING PAYMENT BY ID: $paymentId');

    final response = await api.get(
      '/api/v1/admin/payment/$paymentId',
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ??
            'Failed to fetch payment details',
      );
    }

    return PaymentDetail.fromJson(data['responseBody']);
  }

  /// ==============================
  /// LOCAL DB ADD PAYMENT (OFFLINE)
  /// ==============================
  // Future<void> addPayment(Payment payment, File? attachment) async {
  //   try {
  //     await _dbHelper.createPaymentsTableIfNotExists();
  //
  //     String? attachmentUrl;
  //
  //     if (attachment != null) {
  //       attachmentUrl = await _saveAttachment(
  //         attachment,
  //         payment.id,
  //       );
  //     }
  //
  //     final db = await _dbHelper.database;
  //
  //     await db.insert('payments', {
  //       'id': payment.id,
  //       'member_id': payment.memberId,
  //       'amount': payment.amount,
  //       'payment_date': payment.paymentDate.millisecondsSinceEpoch,
  //       'payment_method': payment.paymentMethod,
  //       'purpose': payment.purpose,
  //       'receipt_number': payment.receiptNumber,
  //       'bank_reference': payment.bankReference,
  //       'status': payment.status,
  //       'notes': payment.notes,
  //       'attachment_url': attachmentUrl,
  //       'created_at': DateTime.now().millisecondsSinceEpoch,
  //       'updated_at': DateTime.now().millisecondsSinceEpoch,
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to add payment locally: $e');
  //   }
  // }

  /// ==============================
  /// SAVE ATTACHMENT LOCALLY
  /// ==============================
  Future<String> _saveAttachment(
      File attachment,
      String paymentId,
      ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final paymentDir = Directory(
      path.join(appDir.path, 'payments', paymentId),
    );

    if (!await paymentDir.exists()) {
      await paymentDir.create(recursive: true);
    }

    final extension = path.extension(attachment.path);
    final fileName =
        'attachment_${DateTime.now().millisecondsSinceEpoch}$extension';

    final savedFile = await attachment.copy(
      path.join(paymentDir.path, fileName),
    );

    return savedFile.path;
  }

  /// ==============================
  /// MAKE PAYMENT (API)
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

    final response = await api.post(
      '/api/v1/admin/payment/pay',
      body: payload,
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 &&
        response.statusCode != 201) {

      final message = data['responseMessage']?.toString() ?? '';

      // 🔥 HANDLE DB NUMERIC OVERFLOW (12 BILLION ISSUE)
      if (message.contains('numeric field overflow') ||
          message.contains('precision 10') ||
          message.contains('10^8')) {
        throw Exception(
          'Amount exceeds allowed limit. Maximum allowed is ₦99,999,999.99',
        );
      }

      throw Exception(
        message.isNotEmpty ? message : 'Payment failed',
      );
    }
  }
}