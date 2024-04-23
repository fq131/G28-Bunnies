import 'package:flutter/material.dart';
import 'package:yumify/screen/navigator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: AnimatedContainer(
            curve: Curves.bounceIn,
            duration: const Duration(seconds: 3),
            width: 110.0, // Adjust width as needed
            height: 110.0, // Adjust height as needed
            child: Image.asset(
              'assets/images/lightmode_icon.png',
              fit: BoxFit.contain, // Adjust fit as needed
            ),
          ),
        ),
      ),
    );
  }
}
