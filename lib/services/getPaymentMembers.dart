import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/getPayment.dart';
import '../models/payment.dart';

class PaymentApiService {
  final String baseUrl;

  PaymentApiService({required this.baseUrl});

  Future<PaymentResponse> fetchPayments(String token) async {
    final url = Uri.parse('$baseUrl/api/v1/admin/payment');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return PaymentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch payments');
    }
  }
}