import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glow_button.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent],
                  ).createShader(bounds),
                  child: const Icon(Icons.language, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 32),
                GlassContainer(
                  child: Column(
                    children: [
                      const Text(
                        '???? ???????? ?????? ??????????????????',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Which language do you prefer?',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      GlowButton(
                        text: '????? (Tamil)',
                        onPressed: () => context.push('/onboarding/categories', extra: 'ta'),
                        glowColor: Colors.purpleAccent,
                      ),
                      const SizedBox(height: 16),
                      GlowButton(
                        text: 'English',
                        onPressed: () => context.push('/onboarding/categories', extra: 'en'),
                        glowColor: Colors.cyanAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

