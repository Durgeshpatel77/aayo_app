import 'package:flutter/material.dart';

class Animatelogo extends StatefulWidget {
  const Animatelogo({super.key});

  @override
  State<Animatelogo> createState() => _AnimatelogoState();
}

class _AnimatelogoState extends State<Animatelogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..forward();
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Image.asset("images/applogos.jpg"),
    );
  }
}
