<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# macos_dock

A Flutter widget that recreates the macOS dock effect with smooth animations and customizable parameters.

## Live Example

Check out the live demo: [MacOS Dock Demo](https://master-wayne7.github.io/macos_dock/)

## Features

- 🔄 Smooth scaling animation on hover
- ⬆️ Upward translation effect
- 🎯 Neighboring icons scale effect
- 🎨 Highly customizable parameters
- 🖼️ Support for any widget as dock items
- ↕️ Dynamic height adjustment
- 🎬 Customizable animation duration

![MacOS Dock Demo](https://raw.githubusercontent.com/yourusername/macos_dock/main/example/demo.gif)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  macos_dock: ^1.0.1
```

## Usage

```dart
MacosDock(
  iconSize: 50,
  scaleFactor: 1.5,
  translateFactor: 1.0,
  children: (scale) => [
    Image.asset('assets/finder.png'),
    Image.asset('assets/safari.png'),
    Image.asset('assets/messages.png'),
  ],
)
```

### Customization

The dock can be customized with several parameters:

```dart
MacosDock(
  iconSize: 50,              // Base size of icons
  iconSpacing: 8,           // Space between icons
  scaleFactor: 1.5,         // How much icons scale up
  translateFactor: 1.0,     // How much icons move up
  radiusFactor: 1.0,        // Spread of the hover effect
  defaultMaxScale: 2.5,     // Maximum scale factor
  defaultMaxTranslate: -30, // Maximum upward translation
  animationDuration: const Duration(milliseconds: 200),
  children: (scale) => [
    // Your dock items here
  ],
)
```

## Additional Parameters

- `iconSize`: Base size of the icons (default: 40)
- `iconSpacing`: Space between icons (default: 8)
- `scaleFactor`: Controls the magnitude of the scaling effect (default: 1)
- `translateFactor`: Controls the magnitude of the upward translation (default: 1)
- `radiusFactor`: Controls how far the scaling effect spreads to neighboring icons (default: 1)
- `defaultMaxScale`: Maximum scale factor for icons (default: 2.5)
- `defaultMaxTranslate`: Maximum upward translation in pixels (default: -30)
- `animationDuration`: Duration of the scaling/translation animations (default: 200ms)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
