import 'package:flutter/material.dart';

/// A widget that displays the FinWise app logo.
///
/// The logo asset `assets/FinwiseLogo.jpeg` is declared in `pubspec.yaml`
/// under the `assets` section. This widget provides a convenient way to
/// embed the logo throughout the app without repeating the asset path.
class FinwiseLogo extends StatelessWidget {
  const FinwiseLogo({super.key, this.width, this.height, this.fit});

  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/FinwiseLogo.jpeg',
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }
}
