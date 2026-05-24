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
      case OrbState.listening: return const Color(0xFF00FF88);
      case OrbState.thinking: return const Color(0xFFFFAA00);
      case OrbState.speaking: return const Color(0xFF00D4FF);
      case OrbState.idle: return const Color(0xFF0066FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.scale(
        scale: widget.state == OrbState.idle ? 1.0 : _pulse.value,
        child: SizedBox(
          width: 120, height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.state != OrbState.idle)
                Transform.rotate(
                  angle: _rotate.value,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _primaryColor.withOpacity(0.3), width: 1),
                    ),
                  ),
                ),
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryColor.withOpacity(0.5), width: 1.5),
                  boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                ),
              ),
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_primaryColor.withOpacity(0.9), _primaryColor.withOpacity(0.4), const Color(0xFF050A14)],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [BoxShadow(color: _primaryColor.withOpacity(0.6), blurRadius: 25, spreadRadius: 5)],
                ),
                child: Icon(_stateIcon, color: Colors.white, size: 28),
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
