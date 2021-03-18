import 'package:flutter/material.dart';

class BleSettingsScreen extends PopupRoute {
  static const route = '/ble-settings';

  static Route createRoute() => BleSettingsScreen(
        settings: RouteSettings(
          name: route,
        ),
      );

  BleSettingsScreen({RouteSettings settings}) : super(settings: settings);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text("you have to enable BT"),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Color get barrierColor => Colors.black;

  @override
  bool get barrierDismissible => false;

  @override
  String get barrierLabel => '';

  @override
  Duration get transitionDuration => Duration(seconds: 3);
}
