import 'location_location.dart';

class AddLocationResponse {
  final bool responseSuccessful;
  final String responseMessage;
  final Location responseBody;

  AddLocationResponse({
    required this.responseSuccessful,
    required this.responseMessage,
    required this.responseBody,
  });

  factory AddLocationResponse.fromJson(Map<String, dynamic> json) {
    return AddLocationResponse(
      responseSuccessful: json['responseSuccessful'],
      responseMessage: json['responseMessage'],
      responseBody: Location.fromJson(json['responseBody']),
    );
  }
}