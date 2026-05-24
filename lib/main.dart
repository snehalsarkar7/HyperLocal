import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'splash_screen.dart';
import 'weather_page.dart';

class SensorReading {
  final int id;
  final String timestamp;
  final double temperature;
  final double humidity;
  final double moisture;

  SensorReading({
    required this.id,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.moisture,
  });
}

final List<SensorReading> mockReadings = [
  SensorReading(
    id: 4,
    timestamp: "2025-11-07T14:45:00",
    temperature: 16.0,
    humidity: 14.0,
    moisture: 20.0,
  ),
];

final SensorReading latestReading = mockReadings.first;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyperlocal IoT',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent, // Let gradient show through
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedFilter = '12h';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D0D1A), // Deep midnight blue
            Color(0xFF1A1A2E), // Darker slate
            Color(0xFF0F0F1A), // Almost black
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF18FFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Hyper Local Station',
              style: TextStyle(
                color: Colors.white, // Required for ShaderMask
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
              tooltip: 'Global Weather',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherPage()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGaugeCard(
                context,
                title: 'TEMPERATURE',
                value: latestReading.temperature,
                unit: '°C',
                minimum: -20,
                maximum: 60,
                icon: Icons.thermostat_outlined,
                iconColor: const Color(0xFFFF9800),
                gradientColors: const [Color(0xFFFFD54F), Color(0xFFFF9800)],
              ),
              const SizedBox(height: 24),

              // Soil Moisture Glass Card
              _buildGlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOIL MOISTURE',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF18FFFF), // Cyan text
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${latestReading.moisture.toStringAsFixed(0)}%',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      width: constraints.maxWidth * (latestReading.moisture / 100),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF00E676), Color(0xFF18FFFF)],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF18FFFF).withValues(alpha: 0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          _buildTimeFilterChip(context, '12h'),
                          const SizedBox(width: 10),
                          _buildTimeFilterChip(context, '1d'),
                          const SizedBox(width: 10),
                          _buildTimeFilterChip(context, '1wk'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildGaugeCard(
                context,
                title: 'HUMIDITY',
                value: latestReading.humidity,
                unit: '%',
                minimum: 0,
                maximum: 100,
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFF00E5FF),
                gradientColors: const [Color(0xFF00E5FF), Color(0xFFD500F9)],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGaugeCard(
    BuildContext context, {
    required String title,
    required double value,
    required String unit,
    required double minimum,
    required double maximum,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF221E36), // Deep purple/navy card background
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    startAngle: 150,
                    endAngle: 30,
                    minimum: minimum,
                    maximum: maximum,
                    showLabels: false,
                    showTicks: false,
                    radiusFactor: 0.9,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.12,
                      cornerStyle: CornerStyle.bothFlat,
                      color: const Color(0xFF4A3E6D).withValues(alpha: 0.3),
                      thicknessUnit: GaugeSizeUnit.factor,
                      dashArray: const <double>[5, 4],
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: value,
                        width: 0.12,
                        sizeUnit: GaugeSizeUnit.factor,
                        cornerStyle: CornerStyle.bothFlat,
                        dashArray: const <double>[5, 4],
                        gradient: SweepGradient(
                          colors: gradientColors,
                        ),
                      ),
                      MarkerPointer(
                        value: value,
                        markerType: MarkerType.rectangle,
                        color: Colors.white,
                        markerHeight: 18,
                        markerWidth: 5,
                        borderWidth: 0,
                        elevation: 4,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -2,
                              ),
                            ),
                            Text(
                              unit,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.1,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterChip(BuildContext context, String text) {
    bool isSelected = selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18FFFF).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF18FFFF) : Colors.white.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF18FFFF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
