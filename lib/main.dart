import 'dart:io';

import 'package:bluetooth_ft/ui/screen/bluetooth_off_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_ft/core/constants/colors/colors.dart';
import 'package:getwidget/getwidget.dart';
import 'core/constants/styles/styles.dart';
import 'ui/screen/device_screen.dart';
import 'ui/widgets/scan_result_tile.dart';
import 'ui/widgets/title_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blue Plus',
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    var hasConnectedDevice = false;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
          actions: [
            GFButton(
              onPressed: Platform.isAndroid
                  ? () => FlutterBluePlus.instance.turnOff()
                  : null,
              type: GFButtonType.transparent,
              child: Text(
                Platform.isAndroid ? 'TURN OFF' : '',
                style: AppStyle.textBody3,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => FlutterBluePlus.instance
              .startScan(timeout: const Duration(seconds: 4)),
          edgeOffset: 10,
          displacement: 0,
          strokeWidth: 2,
          color: AppColors.refreshIndicator,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20.0,
                ),
                StreamBuilder<List<BluetoothDevice>>(
                    stream: Stream.periodic(const Duration(seconds: 4))
                        .asyncMap(
                            (_) => FlutterBluePlus.instance.connectedDevices),
                    initialData: const [],
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        hasConnectedDevice = snapshot.data!.isNotEmpty;
                        if (snapshot.data!.isNotEmpty) {
                          return Container(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              margin:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white),
                              child: Column(
                                children: [
                                  const TitleText(
                                      captionText: 'CONNECTED DEVICES'),
                                  Column(
                                    children: snapshot.data!
                                        .map((d) => ListTile(
                                              title: Text(d.name),
                                              subtitle: Text(d.id.toString()),
                                              trailing: StreamBuilder<
                                                  BluetoothDeviceState>(
                                                stream: d.state,
                                                initialData:
                                                    BluetoothDeviceState
                                                        .disconnected,
                                                builder: (c, snapshot) {
                                                  if (snapshot.data ==
                                                      BluetoothDeviceState
                                                          .connected) {
                                                    return GFButton(
                                                      onPressed: () => Navigator
                                                              .of(context)
                                                          .push(MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DeviceScreen(
                                                                      device:
                                                                          d))),
                                                      type:
                                                          GFButtonType.outline,
                                                      color: AppColors
                                                          .searchButton,
                                                      textColor: AppColors
                                                          .searchButton,
                                                      child: const Text('OPEN'),
                                                    );
                                                  }
                                                  return Text(
                                                      snapshot.data.toString());
                                                },
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ));
                        } else {
                          return Container();
                        }
                      } else {
                        hasConnectedDevice = false;
                        debugPrint('HAS CONNECTED DEVICE $hasConnectedDevice');
                        return Container();
                      }
                    }),
                const SizedBox(
                  height: 20.0,
                ),
                StreamBuilder<List<ScanResult>>(
                    stream: FlutterBluePlus.instance.scanResults,
                    initialData: const [],
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return Container(
                              margin:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white),
                              child: Column(
                                children: <Widget>[
                                  const TitleText(captionText: 'BLE DEVICES'),
                                  Column(
                                    children: snapshot.data!
                                        .where((element) =>
                                            element.device.type ==
                                            BluetoothDeviceType.le)
                                        .map((e) => ScanResultTile(
                                              result: e,
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  e.device.connect();
                                                  return DeviceScreen(
                                                      device: e.device);
                                                },
                                              )),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ));
                        } else {
                          return SizedBox(
                            height: _size.height,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const Icon(Icons.hourglass_empty),
                                  Text(
                                    'NO DEVICES. \n PLEASE CLICK SEARCH DEVICES BUTTON',
                                    style: AppStyle.textBody4,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        return const Center(
                          child: Icon(Icons.hourglass_empty),
                        );
                      }
                    }),
                const SizedBox(
                  height: 20.0,
                ),
                StreamBuilder<List<ScanResult>>(
                    stream: FlutterBluePlus.instance.scanResults,
                    initialData: const [],
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return Container(
                              margin:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0)),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white),
                              child: Column(
                                children: <Widget>[
                                  const TitleText(
                                      captionText: 'ANOTHER DEVICES'),
                                  Column(
                                    children: snapshot.data!
                                        .where((element) =>
                                            element.device.type !=
                                            BluetoothDeviceType.le)
                                        .map((e) => ScanResultTile(
                                              result: e,
                                              onTap: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) {
                                                  e.device.connect();
                                                  return DeviceScreen(
                                                      device: e.device);
                                                },
                                              )),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ));
                        } else {
                          return SizedBox(
                            height: _size.height,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                   const Icon(Icons.hourglass_empty),
                                  Text(
                                    'NO DEVICES. \n PLEASE CLICK SEARCH DEVICES BUTTON',
                                    style: AppStyle.textBody4,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        return const Center(
                          child: Icon(Icons.hourglass_empty),
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBluePlus.instance.isScanning,
          initialData: false,
          builder: (context, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton(
                onPressed: () => FlutterBluePlus.instance.stopScan(),
                backgroundColor: Colors.white,
                child: const Icon(Icons.bluetooth),
              );
            } else {
              return FloatingActionButton(
                backgroundColor: Colors.transparent,
                child:  const Icon(Icons.bluetooth),
                onPressed: () => FlutterBluePlus.instance
                    .startScan(timeout: const Duration(seconds: 4)),
              );
            }
          },
        ));
  }
}


