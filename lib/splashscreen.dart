import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application_3/main.dart';
import 'package:rive/rive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  RiveAnimationController? _controller;

  final List<String> _animationSequence = ['MoveEye'];

  int _currentAnimationIndex = 0;

  @override
  void initState() {
    super.initState();
    _playNextAnimation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _playNextAnimation() {
    if (_currentAnimationIndex < _animationSequence.length) {
      final nextAnimationName = _animationSequence[_currentAnimationIndex];
      debugPrint("Reproduzindo animação: $nextAnimationName");

      final nextAnimation = SimpleAnimation(nextAnimationName);

      nextAnimation.isActiveChanged.addListener(() {
        if (!nextAnimation.isActive) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _currentAnimationIndex++;
            _playNextAnimation();
          });
        }
      });

      _controller?.dispose();
      _controller = nextAnimation;
      setState(() {});
    } else {
      debugPrint("Sequência completa! Splash finalizado.");
      // Aqui você pode navegar para a próxima tela
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TelaInicial()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffBEA073),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: _controller == null
              ? const SizedBox.shrink()
              : RiveAnimation.asset(
                  'assets/animation/EyeOfRah.riv',
                  controllers: [_controller!],
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
