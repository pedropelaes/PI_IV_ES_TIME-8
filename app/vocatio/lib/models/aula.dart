import 'package:vocattio/models/presenca.dart';
import 'package:vocattio/utils/date_formater.dart';

class Aula {
  final String objectId;
  final String turmaId;
  final String codigo;
  final bool aberta;
  final double latitude;
  final double longitude;
  final DateTime dataAbertura;
  final List<Presenca> presentes;
  final DateTime? dataFechamento;

  const Aula({
    required this.objectId,
    required this.turmaId,
    required this.codigo,
    required this.aberta,
    required this.latitude,
    required this.longitude,
    required this.dataAbertura,
    required this.presentes,
    this.dataFechamento,
  });

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      objectId: json['_id'] as String,
      turmaId: json['turmaId'] as String,
      codigo: json['codigo'] as String,
      aberta: json['aberta'] as bool,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      dataAbertura: DateParser.parseCustomDate(json['dataAbertura']),
      presentes: (json['presentes'] as List)
        .map((item) => Presenca.fromJson(item as Map<String, dynamic>))
        .toList(),
      dataFechamento: json['dataFechamento'] == null
          ? null
          : DateParser.parseCustomDate(json['dataFechamento']),
    );
  }

}