import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() {
  runApp(const ColorSelectorApp());
}

enum ColorSpace { sRGB, displayP3 }

class WideColor {
  final double a;
  final double r;
  final double g;
  final double b;
  final ColorSpace colorSpace;

  WideColor.fromARGB(this.a, this.r, this.g, this.b, this.colorSpace);

  WideColor withRed(double red) => WideColor.fromARGB(a, red, g, b, colorSpace);
  WideColor withGreen(double green) =>
      WideColor.fromARGB(a, r, green, b, colorSpace);
  WideColor withBlue(double blue) =>
      WideColor.fromARGB(a, r, g, blue, colorSpace);

  WideColor toSRGB() {
    if (colorSpace == ColorSpace.sRGB) {
      return this;
    } else {
      return Matrix(<double>[
        1.22494, -0.22494, 0, //
        -0.0420568, 1.04206, 0, //
        -0.0196327, -0.0788819, 1.09851
      ]).transform(this, ColorSpace.sRGB);
    }
  }

  WideColor toDisplayP3() {
    if (colorSpace == ColorSpace.displayP3) {
      return this;
    } else {
      return Matrix(<double>[
        0.8224621, 0.1775379, 0.0000000, //
        0.0331941, 0.9668059, 0.0000000, //
        0.0170827, 0.0725972, 0.9103202
      ]).transform(this, ColorSpace.displayP3);
    }
  }
}

class Matrix {
  final List<double> values;

  /// Row-major.
  Matrix(this.values);

  WideColor transform(WideColor color, ColorSpace resultColorSpace) {
    return WideColor.fromARGB(
        color.a,
        values[0] * color.r + values[1] * color.g + values[2] * color.b,
        values[3] * color.r + values[4] * color.g + values[5] * color.b,
        values[6] * color.r + values[7] * color.g + values[8] * color.b,
        resultColorSpace);
  }
}

Future<ui.Image> createSolidColorImage(
    WideColor color, int width, int height) async {
  WideColor srgbColor = color.toSRGB();
  final pixels = Float32List.fromList(
    List.generate(width * height * 4, (index) {
      final pixelIndex = index ~/ 4;
      final x = pixelIndex % width;
      final y = pixelIndex ~/ width;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        switch (index % 4) {
          case 0:
            return srgbColor.r;
          case 1:
            return srgbColor.g;
          case 2:
            return srgbColor.b;
          case 3:
            return srgbColor.a;
        }
      }
      return 0;
    }),
  );

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
      Uint8List.view(pixels.buffer), width, height, ui.PixelFormat.rgbaFloat32,
      (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

class ColorSelectorApp extends StatelessWidget {
  const ColorSelectorApp({super.key});
  final Color foo = const ui.Color.fromARGB(255, 169, 10, 10);

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
  WideColor _leftColor = WideColor.fromARGB(1, 1, 0, 0, ColorSpace.sRGB);
  WideColor _rightColor = WideColor.fromARGB(1, 1, 0, 0, ColorSpace.sRGB);
  ui.Image? _leftPreview;
  ui.Image? _rightPreview;

  @override
  void initState() {
    _generateLeftColorImage();
    _generateRightColorImage();
  }

  void _updateColor(WideColor color) {
    setState(() {
      _leftColor = color.toSRGB();
      _rightColor = color.toDisplayP3();
    });
    _generateLeftColorImage();
    _generateRightColorImage();
  }

  void _generateLeftColorImage() async {
    final image = await createSolidColorImage(_leftColor, 100, 100);
    setState(() {
      _leftPreview = image;
    });
  }

  void _generateRightColorImage() async {
    final image = await createSolidColorImage(_rightColor, 100, 100);
    setState(() {
      _rightPreview = image;
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
                onColorChanged: (color) => _updateColor(color),
                preview: _leftPreview,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ColorSelector(
                  label: 'DisplayP3',
                  color: _rightColor,
                  onColorChanged: (color) => _updateColor(color),
                  preview: _rightPreview),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorSelector extends StatelessWidget {
  final String label;
  final WideColor color;
  final ValueChanged<WideColor> onColorChanged;
  final ui.Image? preview;

  const ColorSelector(
      {super.key,
      required this.label,
      required this.color,
      required this.onColorChanged,
      required this.preview});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label),
        if (preview == null)
          Container(
            height: 100,
            width: 100,
            color: Colors.grey,
          )
        else
          RawImage(image: preview, width: 100.0, height: 100.0),
        const SizedBox(height: 16),
        ColorSlider(
          label: 'Red',
          value: color.r,
          onChanged: (value) {
            onColorChanged(color.withRed(value));
          },
        ),
        ColorSlider(
          label: 'Green',
          value: color.g,
          onChanged: (value) {
            onColorChanged(color.withGreen(value));
          },
        ),
        ColorSlider(
          label: 'Blue',
          value: color.b,
          onChanged: (value) {
            onColorChanged(color.withBlue(value));
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
    return Column(
      children: [
        Row(
          children: [
            Text('$label: '),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: -0.5,
          max: 2.0,
          onChanged: onChanged,
        )
      ],
    );
  }
}
