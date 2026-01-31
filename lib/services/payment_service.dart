import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/payment.dart';
import 'database_helper.dart';

class PaymentService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> addPayment(Payment payment, File? attachment) async {
    try {
      // Ensure payments table exists
      await _dbHelper.createPaymentsTableIfNotExists();

      String? attachmentUrl;

      if (attachment != null) {
        attachmentUrl = await _saveAttachment(attachment, payment.id);
      }

      final db = await _dbHelper.database;

      await db.insert('payments', {
        'id': payment.id,
        'member_id': payment.memberId,
        'amount': payment.amount,
        'payment_date': payment.paymentDate.millisecondsSinceEpoch,
        'payment_method': payment.paymentMethod,
        'purpose': payment.purpose,
        'receipt_number': payment.receiptNumber,
        'bank_reference': payment.bankReference,
        'status': payment.status,
        'notes': payment.notes,
        'attachment_url': attachmentUrl,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }

  Future<String> _saveAttachment(File attachment, String paymentId) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to save attachment: $e');
    }
  }

  Stream<List<Payment>> getPayments() async* {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        orderBy: 'payment_date DESC',
      );

      final payments = maps.map((map) => _paymentFromMap(map)).toList();
      yield payments;
    } catch (e) {
      yield [];
    }
  }

  Future<List<Payment>> getPaymentsSync() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        orderBy: 'payment_date DESC',
      );

      return maps.map((map) => _paymentFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Payment>> getPaymentsByMember(String memberId) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        where: 'member_id = ?',
        whereArgs: [memberId],
        orderBy: 'payment_date DESC',
      );

      return maps.map((map) => _paymentFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Payment>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        where: 'payment_date >= ? AND payment_date <= ?',
        whereArgs: [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'payment_date DESC',
      );

      return maps.map((map) => _paymentFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Payment?> getPaymentById(String id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _paymentFromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePayment(Payment payment) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'payments',
        {
          'member_id': payment.memberId,
          'amount': payment.amount,
          'payment_date': payment.paymentDate.millisecondsSinceEpoch,
          'payment_method': payment.paymentMethod,
          'purpose': payment.purpose,
          'receipt_number': payment.receiptNumber,
          'bank_reference': payment.bankReference,
          'status': payment.status,
          'notes': payment.notes,
          'attachment_url': payment.attachmentUrl,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [payment.id],
      );
    } catch (e) {
      throw Exception('Failed to update payment: $e');
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('payments', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }

  Future<double> getTotalPaymentsByMember(String memberId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM payments WHERE member_id = ? AND status = "Completed"',
        [memberId],
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getTotalPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM payments WHERE payment_date >= ? AND payment_date <= ? AND status = "Completed"',
        [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      );

      if (result.isNotEmpty && result.first['total'] != null) {
        return (result.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<List<Payment>> getRecentPayments({int limit = 10}) async {
    try {
      // Ensure payments table exists
      await _dbHelper.createPaymentsTableIfNotExists();

      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'payments',
        orderBy: 'payment_date DESC',
        limit: limit,
      );

      return maps.map((map) => _paymentFromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  Payment _paymentFromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      memberId: map['member_id'],
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['payment_date']),
      paymentMethod: map['payment_method'],
      purpose: map['purpose'],
      receiptNumber: map['receipt_number'],
      bankReference: map['bank_reference'],
      status: map['status'],
      notes: map['notes'],
      attachmentUrl: map['attachment_url'],
    );
  }
}
