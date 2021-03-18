import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
//import 'package:location/location.dart' as LocationManager;
//import 'package:permission_handler/permission_handler.dart';
import 'package:system_setting/system_setting.dart';

class BLE {
  final bleManager = BleManager();
  //final locationManager = LocationManager.Location();

  log(object) {
    if (kDebugMode) print(object);
  }

  Future<void> init() {
    return bleManager.createClient();
    //bleManager.setLogLevel(LogLevel.verbose);
  }

  Future<void> dispose() {
    bleManager.destroyClient();
  }

  Future<bool> requestPermissions() async {
    //if (Platform.isAndroid &&
    //    await Permission.location.request() != PermissionStatus.granted)
      return Future.error(Exception("Location permission not granted"));
  }

  Future<bool> isBluetoothActive() async {
    return (await bleManager.bluetoothState()) == BluetoothState.POWERED_ON;
  }

  Future<void> requestBluetoothService() {
    SystemSetting.goto(SettingTarget.BLUETOOTH);
  }

  Future<bool> isLocationActive() {
    //return locationManager.serviceEnabled();
  }

  Future<bool> requestLocationServices() {
    //return locationManager.requestService();
  }

  Stream<ScanResult> scan([List<String> uuids = const []]) async* {
    await stopScan();
    List<ScanResult> results = [];
    await for (final scanResult
        in bleManager.startPeripheralScan(uuids: uuids)) {
      if (results.any((previous) =>
          previous.peripheral.identifier == scanResult.peripheral.identifier))
        continue;
      results.add(scanResult);
      if (kDebugMode) print('''ScanResult:
            localName=${scanResult.advertisementData.localName}
            manufacturerData=${scanResult.advertisementData.manufacturerData}
            serviceData=${scanResult.advertisementData.serviceData}
            serviceUuids=${scanResult.advertisementData.serviceUuids}''');
      yield scanResult;
    }
  }

  Future<void> stopScan() {
    return bleManager.stopPeripheralScan();
  }

  Future<Map<Service, List<Characteristic>>> connect(
      Peripheral peripheral) async {
    if (await peripheral.isConnected())
      return Future.error(Exception("device is already connected"));
    stopScan();
    final Completer<Map<Service, List<Characteristic>>> completer = Completer();
    final Map<Service, List<Characteristic>> services = {};
    StreamSubscription subscription;
    subscription = peripheral
        .observeConnectionState(emitCurrentValue: true)
        .listen((state) async {
      log("${peripheral.identifier} state=$state");
      switch (state) {
        case PeripheralConnectionState.connected:
          await peripheral.discoverAllServicesAndCharacteristics();
          for (final service in await peripheral.services()) {
            log(service);
            services[service] = await service.characteristics();
            log(services[service]);
          }
          subscription.cancel();
          if (!completer.isCompleted) completer.complete(services);
          break;
        default:
      }
    });
    await peripheral.connect();
    return completer.future;
  }

  Future<void> disconnect(Peripheral peripheral) {
    return peripheral.disconnectOrCancelConnection();
  }

  Future<Uint8List> writeWithResponse(
      Characteristic characteristic, Uint8List value) async {
    log("w-> $value");
    final result = await (await characteristic.service
            .writeCharacteristic(characteristic.uuid, value, true))
        .read();
    log("<-r $result");
    return result;
  }

  Stream<Uint8List> monitor(Characteristic characteristic) async* {
    await for (final update in characteristic.monitor()) {
      log("<-n $update");
      yield update;
    }
  }
}
