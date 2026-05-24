import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _currentWeather;
  Map<String, dynamic>? _forecastData;
  List<String> _favorites = [];
  String _currentCity = "";
  bool _isUsingLocation = true;

  late AnimationController _iconAnimationController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
          parent: _iconAnimationController, curve: Curves.easeInOutSine),
    );

    _loadFavorites();
    _fetchInitialWeather();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final favs = await _weatherService.getFavorites();
    setState(() {
      _favorites = favs;
    });
  }

  Future<void> _toggleFavorite(String city) async {
    if (_favorites.contains(city)) {
      await _weatherService.removeFavorite(city);
    } else {
      await _weatherService.addFavorite(city);
    }
    await _loadFavorites();
  }

  Future<void> _fetchInitialWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Position position = await _getCurrentLocation();
      _currentWeather = await _weatherService.getWeatherByLocation(
          position.latitude, position.longitude);
      _forecastData = await _weatherService.getForecastByLocation(
          position.latitude, position.longitude);
      _currentCity = _currentWeather!['name'];
      _isUsingLocation = true;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherForCity(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _currentWeather = await _weatherService.getWeatherByCity(city);
      _forecastData = await _weatherService.getForecastByCity(city);
      _currentCity = _currentWeather!['name'];
      _isUsingLocation = false;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not find weather for $city';
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
      return Future.error('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode.replaceAll('n', 'd')) {
      case '01d':
        return FontAwesomeIcons.sun;
      case '02d':
        return FontAwesomeIcons.cloudSun;
      case '03d':
      case '04d':
        return FontAwesomeIcons.cloud;
      case '09d':
      case '10d':
        return FontAwesomeIcons.cloudShowersHeavy;
      case '11d':
        return FontAwesomeIcons.boltLightning;
      case '13d':
        return FontAwesomeIcons.snowflake;
      case '50d':
        return FontAwesomeIcons.smog;
      default:
        return FontAwesomeIcons.sun;
    }
  }

  Color _getWeatherGlowColor(String iconCode) {
    if (iconCode.contains('01') || iconCode.contains('02'))
      return const Color(0xFFFFD54F);
    if (iconCode.contains('n')) return const Color(0xFF90CAF9);
    return const Color(0xFF18FFFF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _isUsingLocation ? 'Current Location' : _currentCity,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _favorites.contains(_currentCity)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _favorites.contains(_currentCity)
                  ? Colors.redAccent
                  : Colors.white,
            ),
            onPressed: () {
              if (_currentWeather != null) {
                _toggleFavorite(_currentCity);
              }
            },
          ),
          if (_favorites.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              color: const Color(0xFF2C274A),
              onSelected: (String city) {
                _fetchWeatherForCity(city);
              },
              itemBuilder: (BuildContext context) {
                return _favorites.map((String city) {
                  return PopupMenuItem<String>(
                    value: city,
                    child:
                        Text(city, style: const TextStyle(color: Colors.white)),
                  );
                }).toList();
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: CitySearchDelegate(_favorites, _fetchWeatherForCity),
              );
              if (result != null && result.isNotEmpty) {
                _fetchWeatherForCity(result);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Base Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF161427),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E1B32), // Dark purple top
                  Color(0xFF161427), // Darker bottom
                ],
              ),
            ),
          ),

          // 2. Foreground Content Layer
          Positioned.fill(
            child: SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF18FFFF)))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(_errorMessage!,
                              style: const TextStyle(color: Colors.white)),
                          TextButton(
                            onPressed: _fetchInitialWeather,
                            child: const Text('Try Again',
                                style: TextStyle(color: Color(0xFF18FFFF))),
                          )
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (_isUsingLocation) {
                          await _fetchInitialWeather();
                        } else {
                          await _fetchWeatherForCity(_currentCity);
                        }
                      },
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        children: [
                          _buildCurrentWeatherHeader(),
                          const SizedBox(height: 30),
                          _buildWeeklyForecast(),
                          const SizedBox(height: 20),
                          _buildSunriseGraph(),
                          const SizedBox(height: 20),
                          _buildWeatherDetails(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C274A)
            .withValues(alpha: 0.6), // Glassy dark purple
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildCurrentWeatherHeader() {
    final double temp = (_currentWeather!['main']['temp'] as num).toDouble();
    final double tempMax =
        (_currentWeather!['main']['temp_max'] as num).toDouble();
    final double tempMin =
        (_currentWeather!['main']['temp_min'] as num).toDouble();
    final String desc = _currentWeather!['weather'][0]['description'];
    final String iconCode = _currentWeather!['weather'][0]['icon'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side: Icon and Condition
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getWeatherGlowColor(iconCode)
                                    .withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                        ),
                        Icon(
                          _getWeatherIcon(iconCode),
                          size: 110,
                          color: _getWeatherGlowColor(iconCode),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              toBeginningOfSentenceCase(desc) ?? desc,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 18),
            ),
          ],
        ),
        // Right side: Temp, H/L, City
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${temp.round()}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w600,
                letterSpacing: -2,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'H:${tempMax.round()}°  L:${tempMin.round()}°',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 35),
            Text(
              _currentCity,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_currentWeather!['sys']['country'] != null)
              Text(
                _currentWeather!['sys']['country'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        )
      ],
    );
  }

  Widget _buildWeeklyForecast() {
    if (_forecastData == null) return const SizedBox.shrink();

    // Group forecast by day
    final Map<String, List<dynamic>> dailyForecasts = {};
    for (var item in _forecastData!['list']) {
      final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
      final dayStr = DateFormat('EEE').format(date); // Mon, Tue, etc.

      if (!dailyForecasts.containsKey(dayStr)) {
        dailyForecasts[dayStr] = [];
      }
      dailyForecasts[dayStr]!.add(item);
    }

    // Get next 5 days
    final List<Widget> dayWidgets = [];
    int count = 0;

    dailyForecasts.forEach((day, items) {
      if (count >= 5) return;

      double dayMax = -100;
      Map<String, int> iconCounts = {};
      double popSum = 0;

      for (var item in items) {
        final double temp = (item['main']['temp'] as num).toDouble();
        if (temp > dayMax) dayMax = temp;

        final String icon = item['weather'][0]['icon'];
        iconCounts[icon] = (iconCounts[icon] ?? 0) + 1;

        if (item['pop'] != null) {
          popSum += (item['pop'] as num).toDouble();
        }
      }

      String mainIcon =
          iconCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      double avgPop = items.isNotEmpty ? (popSum / items.length) * 100 : 0;

      dayWidgets.add(_buildForecastPill(
        day: day,
        iconCode: mainIcon,
        temp: dayMax.round().toString(),
        pop: avgPop > 20 ? avgPop.round() : null,
        isActive: count == 0,
      ));

      count++;
    });

    return _buildGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dayWidgets
              .map((w) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5), child: w))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildForecastPill(
      {required String day,
      required String iconCode,
      required String temp,
      int? pop,
      bool isActive = false}) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4C3E8A)
            : Colors.transparent, // Highlight color
        borderRadius: BorderRadius.circular(40),
        border: isActive
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(day, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 15),
          Icon(_getWeatherIcon(iconCode),
              color: _getWeatherGlowColor(iconCode), size: 28),
          if (pop != null) ...[
            const SizedBox(height: 8),
            Text('$pop%',
                style: const TextStyle(
                    color: Color(0xFF18FFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ] else ...[
            const SizedBox(height: 24), // Spacer if no PoP
          ],
          const SizedBox(height: 10),
          Text('$temp°',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSunriseGraph() {
    if (_currentWeather == null) return const SizedBox.shrink();

    final int sunriseEpoch = _currentWeather!['sys']['sunrise'];
    final int sunsetEpoch = _currentWeather!['sys']['sunset'];
    final int currentEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_twilight, color: Color(0xFFFFD54F), size: 24),
              const SizedBox(width: 10),
              Text(
                'SUNRISE',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: SunriseSunsetPainter(
                sunriseEpoch: sunriseEpoch,
                sunsetEpoch: sunsetEpoch,
                currentEpoch: currentEpoch,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('h:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(sunriseEpoch * 1000)),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
              Text(
                DateFormat('h:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(sunsetEpoch * 1000)),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    if (_currentWeather == null) return const SizedBox.shrink();

    // Extract data
    final double windSpeed =
        (_currentWeather!['wind']['speed'] as num).toDouble();
    final int humidity = _currentWeather!['main']['humidity'];

    // Precipitation
    double rain = 0;
    if (_currentWeather!['rain'] != null) {
      if (_currentWeather!['rain']['1h'] != null) {
        rain = (_currentWeather!['rain']['1h'] as num).toDouble();
      } else if (_currentWeather!['rain']['3h'] != null) {
        rain = (_currentWeather!['rain']['3h'] as num).toDouble();
      }
    }

    return _buildGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDetailItem(FontAwesomeIcons.cloudRain, 'Precipitation',
              '${rain.toStringAsFixed(1)} mm'),
          _buildVerticalDivider(),
          _buildDetailItem(FontAwesomeIcons.wind, 'Wind',
              '${(windSpeed * 3.6).toStringAsFixed(1)} KM/H'),
          _buildVerticalDivider(),
          _buildDetailItem(FontAwesomeIcons.droplet, 'Humidity', '$humidity%'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 16),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

// Painter for Sunrise/Sunset arc
class SunriseSunsetPainter extends CustomPainter {
  final int sunriseEpoch;
  final int sunsetEpoch;
  final int currentEpoch;

  SunriseSunsetPainter(
      {required this.sunriseEpoch,
      required this.sunsetEpoch,
      required this.currentEpoch});

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintActiveLine = Paint()
      ..shader =
          const LinearGradient(colors: [Color(0xFFB388FF), Color(0xFF18FFFF)])
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, -size.height * 0.8, size.width, size.height);

    // Draw full dim path
    canvas.drawPath(path, paintLine);

    // Calculate progress (0.0 to 1.0)
    double progress = 0.0;
    if (currentEpoch >= sunriseEpoch && currentEpoch <= sunsetEpoch) {
      progress = (currentEpoch - sunriseEpoch) / (sunsetEpoch - sunriseEpoch);
    } else if (currentEpoch > sunsetEpoch) {
      progress = 1.0;
    }

    // Clip and draw active path
    if (progress > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(
          0, -size.height, size.width * progress, size.height + 10));
      canvas.drawPath(path, paintActiveLine);
      canvas.restore();
    }

    // Draw horizon line
    canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width, size.height),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..strokeWidth = 2);

    // Draw current sun position
    if (currentEpoch >= sunriseEpoch && currentEpoch <= sunsetEpoch) {
      double t = progress;
      double x = math.pow(1 - t, 2) * 0 +
          2 * (1 - t) * t * (size.width / 2) +
          math.pow(t, 2) * size.width;
      double y = math.pow(1 - t, 2) * size.height +
          2 * (1 - t) * t * (-size.height * 0.8) +
          math.pow(t, 2) * size.height;

      // Draw glow
      canvas.drawCircle(
          Offset(x, y),
          15,
          Paint()
            ..color = const Color(0xFFB388FF).withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      // Draw sun dot
      canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Delegate for City Search
class CitySearchDelegate extends SearchDelegate<String> {
  final List<String> favorites;
  final Function(String) onSearch;
  final WeatherService _weatherService = WeatherService();

  CitySearchDelegate(this.favorites, this.onSearch);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1B32),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
      scaffoldBackgroundColor: const Color(0xFF161427),
      textSelectionTheme:
          const TextSelectionThemeData(cursorColor: Color(0xFF18FFFF)),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        close(context, query);
      });
    }
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.history, color: Colors.white54),
            title: Text(favorites[index],
                style: const TextStyle(color: Colors.white)),
            onTap: () {
              query = favorites[index];
              close(context, query);
            },
          );
        },
      );
    }

    return FutureBuilder<List<String>>(
      future: _weatherService.getCitySuggestions(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF18FFFF)));
        }
        final suggestions = snapshot.data!;
        if (suggestions.isEmpty) {
          return const ListTile(
            title: Text('No suggestions found.',
                style: TextStyle(color: Colors.white54)),
          );
        }
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.location_city, color: Colors.white54),
              title: Text(suggestions[index],
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                query = suggestions[index];
                close(context, query);
              },
            );
          },
        );
      },
    );
  }
}
