import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      // Only parse JSON if the body is valid
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Weather.fromJson(jsonResponse);  // Make sure Weather.fromJson works with the response format
      } catch (e) {
        throw Exception('Error parsing weather data: $e');
      }
    } else {
      throw Exception('Failed to load weather data. Status code: ${response.statusCode}');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    String? city = placemarks[0].locality;
    return city ?? '';
  }
}
