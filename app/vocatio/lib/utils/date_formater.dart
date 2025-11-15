import 'package:intl/intl.dart';

String formatarDataAula(DateTime data) {
  final agora = DateTime.now();
  
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final ontem = DateTime(agora.year, agora.month, agora.day - 1);
  final dataDaAula = DateTime(data.year, data.month, data.day);

  final String horaFormatada = DateFormat('HH:mm').format(data);

  if (dataDaAula == hoje) {
    return 'Hoje - $horaFormatada';
  } else if (dataDaAula == ontem) {
    return 'Ontem - $horaFormatada';
  } else {
    final String dataFormatada = DateFormat('dd/MM/yyyy').format(data);
    return '$dataFormatada - $horaFormatada';
  }
}

class DateParser {
  static DateTime parseCustomDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }

    try {
      // Remove espaçamentos estranhos
      final cleaned = dateString.replaceAll(RegExp(r'\s+'), ' ');

      return DateFormat("MMM d, yyyy, h:mm:ss a", 'en_US').parse(cleaned);
    } catch (e) {
      print("Erro ao converter data: $e");
      return DateTime.now();
    }
  }
}