import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final double size;
  final GlobalKey repaintBoundaryKey; // Key for capturing widget

  const AppIcon({Key? key, this.size = 192, required this.repaintBoundaryKey})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: size,
        height: size * 1.1, // Oval stretch
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.5),
          gradient: RadialGradient(
            colors: [Color(0xFF4DA8DA), Color(0xFF1E2A3C)],
            center: Alignment.center,
            radius: 0.8,
          ),
          border: Border.all(color: Color(0xFF4DA8DA), width: size * 0.01),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.emoji_events, // Trophy
              size: size * 0.5,
              color: Color(0xFFE6ECEF), // Frost White
            ),
            Positioned(
              top: size * 0.4,
              child: Text(
                '😢',
                style: TextStyle(
                  fontSize: size * 0.2,
                  color: Color(0xFFF0544F),
                ), // Fiery Orange
              ),
            ),
            Positioned(
              bottom: size * 0.1,
              right: size * 0.1,
              child: Container(
                padding: EdgeInsets.all(size * 0.04),
                decoration: BoxDecoration(
                  color: Color(0xFF3C4A5C), // Cool Gray
                  border: Border.all(color: Color(0xFFB0BEC5)), // Steel Silver
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '0',
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: Color(0xFFB0BEC5), // Steel Silver
                    shadows: [
                      Shadow(
                        color: Color(0xFFF0544F), // Fiery Orange
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
