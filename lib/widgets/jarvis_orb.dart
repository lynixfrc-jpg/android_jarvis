import 'package:flutter/material.dart';
import 'dart:math' as math;

enum OrbState { idle, listening, thinking, speaking }

class JarvisOrb extends StatefulWidget {
  final OrbState state;
  const JarvisOrb({super.key, required this.state});
  @override
  State<JarvisOrb> createState() => _JarvisOrbState();
}

class _JarvisOrbState extends State<JarvisOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Color get _primaryColor {
    switch (widget.state) {
      case OrbState.listening: return const Color(0xFF00FF41);
      case OrbState.thinking: return const Color(0xFF39FF14);
      case OrbState.speaking: return const Color(0xFF00CC33);
      case OrbState.idle: return const Color(0xFF008F11);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.scale(
        scale: widget.state == OrbState.idle ? 1.0 : _pulse.value,
        child: SizedBox(
          width: 130, height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dış halka
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryColor.withOpacity(0.15), width: 1),
                ),
              ),
              // Dönen halka
              if (widget.state != OrbState.idle)
                Transform.rotate(
                  angle: _rotate.value,
                  child: Container(
                    width: 115, height: 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryColor.withOpacity(0.4), width: 1.5),
                    ),
                  ),
                ),
              // Orta halka
              Container(
                width: 95, height: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryColor.withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: _primaryColor.withOpacity(0.3), blurRadius: 25, spreadRadius: 8),
                  ],
                ),
              ),
              // İç top
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryColor.withOpacity(0.95),
                      _primaryColor.withOpacity(0.5),
                      const Color(0xFF020D02),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(color: _primaryColor.withOpacity(0.7), blurRadius: 30, spreadRadius: 6),
                  ],
                ),
                child: Icon(_stateIcon, color: Colors.black, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _stateIcon {
    switch (widget.state) {
      case OrbState.listening: return Icons.mic;
      case OrbState.thinking: return Icons.psychology;
      case OrbState.speaking: return Icons.volume_up;
      case OrbState.idle: return Icons.assistant;
    }
  }
}
