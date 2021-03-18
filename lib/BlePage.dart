import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'ble.dart';
import 'main.dart';

final blePageProvider = StateNotifierProvider((_) => BlePageStateNotifier());

enum ServiceState { NotReady, Bluetooth, Location, Ready }

class BlePageStateNotifier extends StateNotifier<ServiceState> {
  BlePageStateNotifier() : super(ServiceState.NotReady);

  Future<ServiceState> determineState() async {
    print("inside determineState");
    if (!(await ble.isBluetoothActive())) {
      print("determineState: ble not active");
      state = ServiceState.Bluetooth;
    } else if (Platform.isAndroid && !await ble.isLocationActive()) {
      print("determineState: location not active");
      state = ServiceState.Location;
    } else {
      print("determineState: ready");
      state = ServiceState.Ready;
    }
    print("state=$state");
    return state;
  }
}

class BlePage extends StatefulHookWidget {
  @override
  Widget build(BuildContext context) {
    final state = useProvider(blePageProvider.state);
    useEffect(() {
      Future.microtask(() => context.read(blePageProvider).determineState());
      return;
    }, [state]);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: getWidget(state),
        ),
      ),
    );
  }

  Widget getWidget(ServiceState state) {
    switch (state) {
      case ServiceState.Ready:
        return ready();
      case ServiceState.Bluetooth:
        return bluetooth();
      case ServiceState.Location:
        return location();
      case ServiceState.NotReady:
      default:
        return Container();
    }
  }

  Widget ready() {
    return Column(
      children: [
        Text("all ready"),
      ],
    );
  }

  Widget bluetooth() {
    return Column(
      children: [
        Text("enable bluetooth"),
      ],
    );
  }

  Widget location() {
    return Column(
      children: [
        Text("enable location"),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
