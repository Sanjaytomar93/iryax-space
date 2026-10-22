import 'package:flutter/material.dart';

/// Displays the IRYAX SPACE logo from the actual brand image asset.
class IryaxLogo extends StatelessWidget {
  final double size;

  const IryaxLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/iryax_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

/// Same logo — no extra wrapping, for use inside coloured containers.
class IryaxLogoInline extends StatelessWidget {
  final double size;
  const IryaxLogoInline({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/iryax_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}