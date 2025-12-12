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
        primarySwatch: Colors.yellow,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF222222),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF222222),
          elevation: 0,
        ),
        cardColor: const Color(0xFF333333),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hyper Local Weather Station',
          style: TextStyle(
              color: Color(0xFF00E676)), // Bright green for title
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
              minimum: -100,
              maximum: 100,
              gaugeColor: const Color(0xFFFFFF00), // Yellow
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soil Moisture',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF00E676)), // Green text
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${latestReading.moisture.toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            color: Colors.amber, // Orange for moisture
                            fontSize: 48,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: latestReading.moisture / 100,
                            backgroundColor: Colors.grey.shade700,
                            color: Colors.blueGrey,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildTimeFilterChip(context, '12h', true),
                        const SizedBox(width: 8),
                        _buildTimeFilterChip(context, '1d', false),
                        const SizedBox(width: 8),
                        _buildTimeFilterChip(context, '1wk', false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildGaugeCard(
              context,
              title: 'Humidity',
              value: latestReading.humidity,
              unit: '%',
              minimum: -100,
              maximum: 100,
              gaugeColor: const Color(0xFF00E676), // Bright green
            ),
            const SizedBox(height: 20),
          ],
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
        required Color gaugeColor,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: gaugeColor),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    startAngle: 150,
                    endAngle: 30,
                    minimum: minimum,
                    maximum: maximum,
                    showLabels: false,
                    showTicks: false,
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: value,
                        enableAnimation: true,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        needleColor: gaugeColor,
                        knobStyle: KnobStyle(color: gaugeColor, knobRadius: 0.08),
                      ),
                    ],
                    axisLineStyle: AxisLineStyle(
                        thickness: 0.1,
                        cornerStyle: CornerStyle.bothCurve,
                        color: Colors.grey.shade700,
                        thicknessUnit: GaugeSizeUnit.factor),
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: minimum,
                        endValue: value,
                        color: gaugeColor,
                        startWidth: 0.1,
                        endWidth: 0.1,
                        sizeUnit: GaugeSizeUnit.factor,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          minimum.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        angle: 150,
                        positionFactor: 1.2,
                      ),
                      GaugeAnnotation(
                        widget: Text(
                          maximum.toStringAsFixed(0),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        angle: 30,
                        positionFactor: 1.2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  '${value.toStringAsFixed(0)} $unit',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: gaugeColor, fontSize: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterChip(
      BuildContext context, String text, bool isSelected) {
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      selectedColor: const Color(0xFF00E676),
      backgroundColor: Theme.of(context).cardColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {

      },
    );
  }
}