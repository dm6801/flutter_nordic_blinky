import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
//import 'package:permission_handler/permission_handler.dart';

import 'ble_settings_screen.dart';
import 'ble.dart' as _BLE;
import 'location_settings_screen.dart';
import 'main_screen.dart';

final ble = _BLE.BLE();

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  final mainPage = MaterialPage(
    key: ValueKey('main-screen'),
    name: 'main-screen',
    child: MainScreen(),
  );

  List<Page> pages = [
    MaterialPage(
      key: ValueKey('2nd'),
      name: '2nd',
      child: Scaffold(body: Center(child: Text('sdgfsgsfgsfgfsgs'))),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope(
        onWillPop: () async => !await _navigatorKey.currentState.maybePop(),
        child: Navigator(
          key: _navigatorKey,
          pages: [
            mainPage,
            ...pages,
          ],
          onPopPage: (route, result) {
            print('abc');
            if (!route.didPop(result)) return false;
            setState(() {
              pages.removeWhere((page) => page.name == route.settings.name);
              print('popped ${route.settings.name}\npages: $pages');
            });
            return true;
          },
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text("Hello World!"),
        ),
      ),
    );
  }
}

/*class App extends StatefulWidget {
  const App({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  StreamSubscription bluetoothSubscription;
  StreamSubscription locationSubscription;
  static final navigatorKey = GlobalKey<NavigatorState>();

  static ModalRoute get currentRoute =>
      ModalRoute.of(navigatorKey.currentContext);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await ble.init();
      observeBluetooth();
      if (Platform.isAndroid) observeLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nordic Blinky',
      navigatorKey: navigatorKey,
      initialRoute: MainScreen.route,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case BleSettingsScreen.route:
            return BleSettingsScreen.createRoute();
          case MainScreen.route:
          default:
            return MainScreen.createRoute();
        }
      },
    );
  }

  void observeBluetooth() async {
    if (ble.bleManager != null) {
      print('listening to bluetooth state..');
      bluetoothSubscription =
          ble.bleManager.observeBluetoothState().listen((update) {
        print('bluetooth state: $update');
        switch (update) {
          case BluetoothState.POWERED_ON:
            navigatorKey.currentState.popUntil(
                (current) => current.settings.name != BleSettingsScreen.route);
            break;
          default:
            if (currentRoute?.settings?.name != BleSettingsScreen.route)
              navigatorKey.currentState.pushNamed(BleSettingsScreen.route);
        }
      });
    }
  }

  void observeLocation() async {
    print('listening to location state..');
    final state = await Permission.locationWhenInUse.serviceStatus;
    print('location state: $state');
    switch (state) {
      case ServiceStatus.enabled:
        navigatorKey.currentState.popUntil(
            (current) => current.settings.name != LocationSettingsScreen.route);
        break;
      default:
        if (currentRoute?.settings?.name != LocationSettingsScreen.route)
          navigatorKey.currentState.pushNamed(LocationSettingsScreen.route);
    }
  }

  @override
  void dispose() {
    ble.dispose();
    bluetoothSubscription?.cancel();
    locationSubscription?.cancel();
    super.dispose();
  }
}*/

/*
const String service_uuid = "00001523-1212-efde-1523-785feabcd123";
const String notify_char = "00001524-1212-efde-1523-785feabcd123";
const String write_char = "00001525-1212-efde-1523-785feabcd123";

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BLE ble = BLE();

  StreamSubscription scanResultsStream;
  ScanResult scanResult;
  Characteristic writeChar;

  @override
  void initState() {
    super.initState();
    ble.init();
  }

  @override
  void dispose() {
    ble.dispose();
    super.dispose();
  }

  /*Future<void> checkPermissions() async {
    if (Platform.isAndroid &&
        await Permission.location.request() != PermissionStatus.granted)
      return Future.error(Exception("Location permission not granted"));
  }*/

  /*Future<void> ensureBluetoothOn() async {
    Completer completer = Completer();
    StreamSubscription<BluetoothState> subscription;
    subscription = bleManager
        .observeBluetoothState(emitCurrentValue: true)
        .listen((bluetoothState) async {
      if (bluetoothState == BluetoothState.POWERED_ON &&
          !completer.isCompleted) {
        await subscription.cancel();
        completer.complete();
      }
    });
    return completer.future;
  }*/

  Future<void> scan() {
    scanResultsStream = ble.scan([service_uuid]).listen((scanResult) {
      if (scanResult.peripheral.name == "Nordic_Blinky")
        this.scanResult = scanResult;
    });
  }

  Future<void> stopScan() {
    scanResultsStream?.cancel();
    scanResultsStream = null;
    return ble.stopScan();
  }

  Future<void> connect(Peripheral peripheral) async {
    (await ble.connect(peripheral)).forEach((service, characteristics) {
      for (final characteristic in characteristics) {
        switch (characteristic.uuid) {
          case notify_char:
            ble.monitor(characteristic).listen((value) {
              //
            });
            break;
          case write_char:
            writeChar = characteristic;
            break;
        }
      }
    });
  }

  Future<void> disconnect() {
    return ble.disconnect(scanResult.peripheral);
  }

  Future<Uint8List> writeWithResponse(Uint8List value) {
    return ble.writeWithResponse(writeChar, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nordic Blinky"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextButton(onPressed: scan, child: Text('scan')),
            TextButton(onPressed: stopScan, child: Text('stop scan')),
            TextButton(
                onPressed: () => connect(scanResult.peripheral),
                child: Text('connect')),
            TextButton(onPressed: disconnect, child: Text('disconnect')),
            TextButton(
              onPressed: () => writeWithResponse(Uint8List.fromList([1])),
              child: Text('write 1'),
            ),
            TextButton(
              onPressed: () => writeWithResponse(Uint8List.fromList([0])),
              child: Text('write 0'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
