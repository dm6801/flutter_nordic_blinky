import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MainScreen extends HookWidget {
  static const route = '/';

  static Route createRoute() {
    return MaterialPageRoute(
      settings: RouteSettings(name: route),
      builder: (context) => const MainScreen(),
    );
  }

  const MainScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text("main page"),
            ],
          ),
        ),
      ),
    );
  }
}
