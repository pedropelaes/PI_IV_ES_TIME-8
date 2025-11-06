class LocPadrao {
  final double latitude;
  final double longitude;

  const LocPadrao({
    required this.latitude,
    required this.longitude
  });

  factory LocPadrao.fromJson(Map<String, dynamic> json){
    return LocPadrao(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}