import 'package:vocattio/utils/date_formater.dart';

class FaltasDoDia {
  final DateTime data;
  final int totalDeFaltas;

  const FaltasDoDia({
    required this.data,
    required this.totalDeFaltas,
  });

  factory FaltasDoDia.fromJson(Map<String, dynamic> json) {
    return FaltasDoDia(
      data: DateParser.parseCustomDate(json['data']),
      totalDeFaltas: json['totalDeFaltas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toIso8601String(),
      'totalDeFaltas': totalDeFaltas,
    };
  }
}