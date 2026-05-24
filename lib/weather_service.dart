import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  static const String _apiKey = "5160a7ac838e097f05921dc299f8377d";
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  Future<Map<String, dynamic>> getWeatherByLocation(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final response = await http.get(Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather for $city');
    }
  }

  Future<Map<String, dynamic>> getForecastByLocation(double lat, double lon) async {
    final response = await http.get(Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load forecast');
    }
  }

  Future<Map<String, dynamic>> getForecastByCity(String city) async {
    final response = await http.get(Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load forecast for $city');
    }
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorite_cities') ?? [];
  }

  Future<void> addFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(city)) {
      favorites.add(city);
      await prefs.setStringList('favorite_cities', favorites);
    }
  }

  Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(city);
    await prefs.setStringList('favorite_cities', favorites);
  }

  Future<String?> getCityImage(String city) async {
    const String pixabayKey = "55768293-84f23d47e2bfeacdd46e32ddf";
    final url = 'https://pixabay.com/api/?key=$pixabayKey&q=${Uri.encodeComponent(city)}+landmark&image_type=photo&orientation=vertical&per_page=3';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['hits'] != null && data['hits'].isNotEmpty) {
          // PROFESSIONAL FIX: 
          // We MUST use `webformatURL` instead of `largeImageURL`.
          // `largeImageURL` serves the raw, unedited camera image containing complex EXIF orientation tags that Android mishandles.
          // `webformatURL` is pre-processed, scaled, and physically auto-oriented by Pixabay, ensuring perfect upright rendering natively.
          String imageUrl = data['hits'][0]['webformatURL'];
          
          if (kIsWeb) {
            // Proxy only required for Web CORS
            return 'https://wsrv.nl/?url=${Uri.encodeComponent(imageUrl)}';
          }
          
          // Mobile uses the direct, pre-processed Pixabay URL
          return imageUrl;
        }
      }
    } catch (e) {
      // Ignore and return null to fallback to gradient
    }
    return null;
  }

  Future<List<String>> getCitySuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await http.get(Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(query)}&limit=5&appid=$_apiKey'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map<String>((item) {
          final city = item['name'];
          final country = item['country'];
          return '$city, $country';
        }).toSet().toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }
}
