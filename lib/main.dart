import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: BoringLauncher(),
    ),
  );
}

class BoringLauncher extends StatelessWidget {
  const BoringLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boring Launcher',
      debugShowCheckedModeBanner: false,
      theme: BoringTheme.dark,
      home: const HomeScreen(),
    );
  }
}
