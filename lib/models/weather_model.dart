class Weather {
  final String? cityName; // Name of the city
  final double temperature; // Temperature in Celsius
  final String? description; // Weather description (e.g., clear sky, rain)
  final double? rainVolume;

  var chanceOfRain; // Chance of rain or rain volume (in mm, last 1 hour)

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    this.rainVolume,
  });

  // Factory constructor to create a Weather object from JSON
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'], // Extract city name
      temperature: json['main']['temp'], // Extract temperature
      description: json['weather'][0]['description'], // Extract weather description
      rainVolume: json.containsKey('rain') && json['rain'] != null
          ? json['rain']['1h']?.toDouble() ?? 0.0
          : 0.0, // Extract rain volume (default is 0.0 if no rain data)
    );
  }
}
