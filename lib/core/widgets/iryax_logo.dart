import 'package:flutter/material.dart';

class IryaxLogo extends StatelessWidget {
  final double size;

  const IryaxLogo({
    super.key,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'iG',
            style: TextStyle(
              color: Color(0xFF171426),
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'IRYAX',
            style: TextStyle(
              color: Color(0xFF777287),
              fontSize: 7,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'SPACE',
            style: TextStyle(
              color: Color(0xFFAAA6B6),
              fontSize: 5.5,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}