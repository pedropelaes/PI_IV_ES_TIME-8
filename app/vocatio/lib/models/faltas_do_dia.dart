class FaltasDoDia {
  final String diaDasemana;
  final int totalDeFaltas;

  const FaltasDoDia({
    required this.diaDasemana,
    required this.totalDeFaltas,
  });

  factory FaltasDoDia.fromJson(Map<String, dynamic> json) {
    return FaltasDoDia(
      diaDasemana: json['diaDaSemana'],
      totalDeFaltas: json['totalDeFaltas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diaDasemana': diaDasemana,
      'totalDeFaltas': totalDeFaltas,
    };
  }
}