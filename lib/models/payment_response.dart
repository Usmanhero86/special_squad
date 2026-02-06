import 'paymentListMembers.dart';

class PaymentPagedResponse {
  final List<Payments> payments;
  final double totalAmount;
  final int total;
  final int page;
  final int limit;

  PaymentPagedResponse({
    required this.payments,
    required this.totalAmount,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaymentPagedResponse.fromJson(Map<String, dynamic> json) {
    final body = json['responseBody'];

    return PaymentPagedResponse(
      payments: (body['data'] as List)
          .map((e) => Payments.fromJson(e))
          .toList(),
      totalAmount:
      double.tryParse(body['totalAmount']?.toString() ?? '0') ?? 0,
      total: body['total'] ?? 0,
      page: body['page'] ?? 1,
      limit: body['limit'] ?? 10,
    );
  }
}