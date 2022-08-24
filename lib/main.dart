import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_ft/core/constants/colors/colors.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lottie/lottie.dart';

import 'core/constants/styles/styles.dart';
import 'screens/widgets/scan_result_tile.dart';
import 'screens/bluetooth_off_screen.dart';

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
                                                      child: const Text('OPEN'),
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

class TitleText extends StatelessWidget {
  final String captionText;

  const TitleText({Key? key, required this.captionText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;

    return Container(
      width: _size.width,
      margin: const EdgeInsets.all(10.0),
      child: Text(captionText,
          style: AppStyle.textHeader2, textAlign: TextAlign.start),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map((s) => ServiceTile(
              service: s,
              characteristicTiles: s.characteristics
                  .map((c) => CharacteristicTile(
                        characteristic: c,
                        streamBluetoothDeviceState: device.state,
                        descriptorTiles: c.descriptors
                            .map(
                              (d) => DescriptorTile(
                                descriptor: d,
                                onReadPressed: () => d.read(),
                                onWritePressed: () =>
                                    d.write('[SP,2,]'.codeUnits),
                              ),
                            )
                            .toList(),
                      ))
                  .toList(),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var isProcess = false;

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              debugPrint('DEVICE STATE ' + snapshot.data.toString());
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  isProcess = false;
                  onPressed = () async => await device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  isProcess = false;
                  onPressed = () async => device.connect();
                  text = 'CONNECT';
                  break;
                case BluetoothDeviceState.connecting:
                  text = '';
                  isProcess = true;
                  break;
                case BluetoothDeviceState.disconnecting:
                  text = '';
                  isProcess = true;
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return Row(
                children: <Widget>[
                  if (isProcess) const Icon(Icons.refresh, color: Colors.red),
                  GFButton(
                      type: GFButtonType.transparent,
                      onPressed: onPressed,
                      child: Text(text.isNotEmpty ? text : '',
                          style: AppStyle.textButton1)),
                ],
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
                stream: device.state,
                initialData: BluetoothDeviceState.connecting,
                builder: (context, snapshot) => ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          snapshot.data == BluetoothDeviceState.connected
                              ? const Icon(
                                  Icons.bluetooth_connected,
                                  color: Colors.blueAccent,
                                )
                              : const Icon(Icons.bluetooth_disabled),
                          snapshot.data == BluetoothDeviceState.connected
                              ? StreamBuilder<int>(
                                  stream: rssiStream(),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.hasData
                                          ? '${snapshot.data}dBm'
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.w500),
                                    );
                                  })
                              : Text(
                                  '',
                                  style: Theme.of(context).textTheme.caption,
                                ),
                        ],
                      ),
                      title: Text(
                          'Device is ${snapshot.data.toString().split('.')[1]}.'),
                      subtitle: Text('${device.id}'),
                      trailing: StreamBuilder<bool>(
                        stream: device.isDiscoveringServices,
                        initialData: false,
                        builder: (context, snapshot) => IndexedStack(
                          index: snapshot.data! ? 1 : 0,
                          children: <Widget>[
                            GFButton(
                              onPressed: () => {
                                device.discoverServices(),
                              },
                              type: GFButtonType.outline,
                              text: 'DISCOVER\nSERVICES',
                              textColor: Colors.black87,
                            ),
                            const IconButton(
                                onPressed: null,
                                icon: SizedBox(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.grey),
                                  ),
                                  width: 18.0,
                                  height: 18.0,
                                )),
                          ],
                        ),
                      ),
                    )),
            StreamBuilder<int>(
                stream: device.mtu,
                initialData: 0,
                builder: (context, snapshot) => ListTile(
                      title: const Text('MTU Size'),
                      subtitle: Text('${snapshot.data} bytes'),
                      trailing: IconButton(
                          onPressed: () => device.requestMtu(223),
                          icon: const Icon(Icons.edit)),
                    )),
            StreamBuilder<List<BluetoothService>>(
                stream: device.services,
                initialData: const [],
                builder: (context, snapshot) {
                  return Column(
                    children: _buildServiceTiles(snapshot.data!),
                  );
                }),
          ],
        ),
      ),
    );
  }

  Stream<int> rssiStream() async* {
    var isConnected = true;
    final subscription = device.state.listen((state) {
      isConnected = state == BluetoothDeviceState.connected;
    });
    while (isConnected) {
      yield await device.readRssi();
      await Future.delayed(const Duration(seconds: 1));
    }
    subscription.cancel();
    // Device disconnected, stopping RSSI stream
  }
}
