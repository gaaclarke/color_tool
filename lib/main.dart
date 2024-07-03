import 'package:flutter/material.dart';

void main() {
  runApp(const ColorSelectorApp());
}

class ColorSelectorApp extends StatelessWidget {
  const ColorSelectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _ColorSelectorPage(),
    );
  }
}

class _ColorSelectorPage extends StatefulWidget {
  const _ColorSelectorPage({super.key});

  @override
  _ColorSelectorPageState createState() => _ColorSelectorPageState();
}

class _ColorSelectorPageState extends State<_ColorSelectorPage> {
  Color _leftColor = Colors.red;
  Color _rightColor = Colors.blue;

  void _updateColor(Color color, bool isLeft) {
    setState(() {
      if (isLeft) {
        _leftColor = color;
        _rightColor = color;
      } else {
        _rightColor = color;
        _leftColor = color;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Tool'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ColorSelector(
                label: 'sRGB',
                color: _leftColor,
                onColorChanged: (color) => _updateColor(color, true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ColorSelector(
                label: 'DisplayP3',
                color: _rightColor,
                onColorChanged: (color) => _updateColor(color, false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSelector extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorSelector(
      {super.key,
      required this.label,
      required this.color,
      required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black38, width: 2),
          ),
        ),
        const SizedBox(height: 16),
        ColorSlider(
          label: 'Red',
          value: color.red.toDouble(),
          onChanged: (value) {
            onColorChanged(color.withRed(value.toInt()));
          },
        ),
        ColorSlider(
          label: 'Green',
          value: color.green.toDouble(),
          onChanged: (value) {
            onColorChanged(color.withGreen(value.toInt()));
          },
        ),
        ColorSlider(
          label: 'Blue',
          value: color.blue.toDouble(),
          onChanged: (value) {
            onColorChanged(color.withBlue(value.toInt()));
          },
        ),
      ],
    );
  }
}

class ColorSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const ColorSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
