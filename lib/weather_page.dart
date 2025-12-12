import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


const String _apiKey = "5160a7ac838e097f05921dc299f8377d";

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return FontAwesomeIcons.sun;
      case '01n': return FontAwesomeIcons.moon;
      case '02d': return FontAwesomeIcons.cloudSun;
      case '02n': return FontAwesomeIcons.cloudMoon;
      case '03d': case '03n': return FontAwesomeIcons.cloud;
      case '04d': case '04n': return FontAwesomeIcons.cloud;
      case '09d': case '09n': return FontAwesomeIcons.cloudShowersHeavy;
      case '10d': return FontAwesomeIcons.cloudSunRain;
      case '10n': return FontAwesomeIcons.cloudMoonRain;
      case '11d': case '11n': return FontAwesomeIcons.boltLightning;
      case '13d': case '13n': return FontAwesomeIcons.snowflake;
      case '50d': case '50n': return FontAwesomeIcons.smog;
      default: return FontAwesomeIcons.sun;
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Position position = await _getCurrentLocation();
      String apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load weather (Server error)';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text('Global Weather'),
        backgroundColor: const Color(0xFF222222),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchWeather,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Center(
        child: _buildWeatherUI(),
      ),
    );
  }

  Widget _buildWeatherUI() {
    if (_isLoading) {
      return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
      );
    }
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $_errorMessage\n\nPlease ensure location is enabled and you have a valid API key.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }
    if (_weatherData == null) {
      return const Text('No weather data found.');
    }
    final String cityName = _weatherData!['name'];
    final double temperature = _weatherData!['main']['temp'];
    final String description = _weatherData!['weather'][0]['description'];
    final String iconCode = _weatherData!['weather'][0]['icon'];
    final IconData weatherIcon = _getWeatherIcon(iconCode);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            cityName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            weatherIcon,
            size: 150,
            color: const Color(0xFF00E676),
          ),
          const SizedBox(height: 20),
          Text(
            '${temperature.toStringAsFixed(1)} °C',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF00E676),
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
              fontSize: 24,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}