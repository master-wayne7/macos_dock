import 'package:flutter/material.dart';
import 'package:macos_dock/macos_dock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MacOS Dock Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double scaleFactor = 1.5;
  double translateFactor = 1.5;
  double radiusFactor = 5;
  double iconSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Dock
          MacosDock(
            scaleFactor: scaleFactor,
            translateFactor: translateFactor,
            radiusFactor: radiusFactor,
            iconSpacing: iconSpacing,
            children: (scale) => [
              Image.asset('assets/Finder.png'),
              Image.asset('assets/App_Store.png'),
              Image.asset('assets/Calendar.png'),
              Image.asset('assets/Apple_Music.png'),
              Image.asset('assets/Apple_TV.png'),
              Image.asset('assets/Brave.png'),
              Image.asset('assets/vscode.png'),
              Image.asset('assets/Spotify.png'),
              Image.asset('assets/discord.png'),
              Image.asset('assets/Control.png'),
              Image.asset('assets/blender.png'),
            ],
          ),

          // Control panel
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSlider(
                    "Scale Factor",
                    scaleFactor,
                    (value) => setState(
                      () => scaleFactor = value,
                    ),
                    max: 5,
                  ),
                  _buildSlider(
                    "Translate Factor",
                    translateFactor,
                    (value) => setState(
                      () => translateFactor = value,
                    ),
                    max: 5,
                  ),
                  _buildSlider(
                    "Radius Factor",
                    radiusFactor,
                    (value) => setState(
                      () => radiusFactor = value,
                    ),
                    max: 15,
                  ),
                  _buildSlider(
                    "Icon Spacing",
                    iconSpacing,
                    (value) => setState(
                      () => iconSpacing = value,
                    ),
                    max: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    ValueChanged<double> onChanged, {
    double max = 15.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: 0.1,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
