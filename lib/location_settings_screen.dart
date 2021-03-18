import 'package:flutter/material.dart';

class LocationSettingsScreen extends PopupRoute {
  static const route = '/ble-settings';

  static Route createRoute() => LocationSettingsScreen(
        settings: RouteSettings(
          name: route,
        ),
      );

  LocationSettingsScreen({RouteSettings settings}) : super(settings: settings);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text("must enable Location"),
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
