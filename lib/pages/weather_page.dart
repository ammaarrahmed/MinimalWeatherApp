import 'package:app1/service/weather_service.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('YOUR API_KEY');
  Weather? _weather;
  String? _errorMessage;
  final TextEditingController _cityController = TextEditingController();

  Future<void> _fetchWeather([String? cityName]) async {
    setState(() {
      _errorMessage = null; // Clear previous errors
    });

    try {
      final weather = await _weatherService.getWeather(cityName ?? await _weatherService.getCurrentCity());
      setState(() {
        _weather = weather;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _showErrorDialog(_errorMessage!);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String getWeatherAnimation(String? description) {
    if (description == null) return 'assets/night.json';
    switch (description.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
      case 'dust':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
      case 'tornado':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Search bar
            SizedBox(
              width: 300, // Set the desired width here
              child: TextField(
                controller: _cityController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[700],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      if (_cityController.text.isNotEmpty) {
                        _fetchWeather(_cityController.text);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Weather details
            Expanded(
              child: Center(
                child: _weather != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _weather!.cityName ?? 'Unknown City',
                            style: const TextStyle(fontSize: 24, color: Colors.white),
                          ),
                          Align(
                            alignment: _weather!.description?.toLowerCase() == 'thunderstorm'
                                ? Alignment.centerLeft
                                : Alignment.center,
                            child: Lottie.asset(
                              getWeatherAnimation(_weather!.description),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            '${_weather!.temperature.round()}°C',
                            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _weather!.description ?? 'No description',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          if (_weather!.rainVolume != null && _weather!.rainVolume! > 0) ...[
                            Text(
                              'Chance of Rain: ${_weather!.rainVolume!.toStringAsFixed(1)} mm',
                              style: const TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                          ] else
                            const Text(
                              'No Rain Expected',
                              style: TextStyle(fontSize: 16, color: Colors.white70),
                            ),
                        ],
                      )
                    : const Text(
                        "Loading weather data...",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchWeather(); // Refresh the weather data
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
