
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:getwidget/getwidget.dart';

import '../../core/constants/styles/styles.dart';
import '../widgets/scan_result_tile.dart';

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
