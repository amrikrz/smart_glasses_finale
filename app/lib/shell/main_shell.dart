import 'package:flutter/material.dart';
import '../screens/camera_screen.dart';
import '../screens/home_screen.dart';
import '../screens/navigation_screen.dart';
import '../screens/translation_screen.dart';
import '../screens/visioai_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenTab: _go),
          const CameraScreen(),
          const NavigationScreen(),
          const TranslationScreen(),
          const VisioAiScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.photo_camera_outlined), label: 'Caméra'),
          NavigationDestination(icon: Icon(Icons.navigation_outlined), label: 'Navigation'),
          NavigationDestination(icon: Icon(Icons.translate), label: 'Traduction'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'VisioAI'),
        ],
      ),
    );
  }
}