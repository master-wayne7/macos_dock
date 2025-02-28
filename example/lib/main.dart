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
      debugShowCheckedModeBanner: false,
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
  bool enableReordering = false;
  Duration animationDuration = const Duration(milliseconds: 200);

  // List to store dock items
  List<String> dockItems = [
    'assets/Finder.png',
    'assets/App_Store.png',
    'assets/Calendar.png',
    'assets/Apple_Music.png',
    'assets/Apple_TV.png',
    'assets/Brave.png',
    'assets/vscode.png',
    'assets/Spotify.png',
    'assets/discord.png',
    'assets/Control.png',
    'assets/blender.png',
  ];

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = dockItems.removeAt(oldIndex);
      dockItems.insert(newIndex, item);
    });
  }

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
            enableReordering: enableReordering,
            onReorder: _handleReorder,
            animationDuration: animationDuration,
            children: (scale) => dockItems
                .map(
                  (item) => Image.asset(item),
                )
                .toList(),
          ),

          // Control panel
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Enable Reordering'),
                    value: enableReordering,
                    onChanged: (value) {
                      setState(() {
                        enableReordering = value;
                      });
                    },
                  ),
                  const Divider(),
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
                  _buildSlider(
                    "Animation Duration (ms)",
                    animationDuration.inMilliseconds.toDouble(),
                    (value) => setState(
                      () => animationDuration =
                          Duration(milliseconds: value.round()),
                    ),
                    min: 0,
                    max: 900,
                    divisions: 90,
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
    double min = 0.1,
    double max = 15.0,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
