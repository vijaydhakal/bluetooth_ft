import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../terminal_screen.dart';
import 'package:getwidget/getwidget.dart';

import '../../core/constants/colors/colors.dart';

class ScanResultTile extends StatelessWidget{

  final ScanResult result;
  final VoidCallback? onTap;

  const ScanResultTile({Key? key, required this.result, this.onTap}) : super(key: key);

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.device.name,
            style: TextStyle(color: result.device.name.isNotEmpty && result.device.name.toLowerCase().contains('golfcar') ? AppColors.iris : Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.caption),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.caption?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceServiceData(Map<String, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add('${id.toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return 'N/A';
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle(context),
      leading: Text(result.rssi.toString()),
      trailing: GFButton(
        onPressed: (result.advertisementData.connectable) ? onTap : null,
        child: const Text('CONNECT'),
        type: GFButtonType.outline,
        color: AppColors.searchButton,
        textColor: AppColors.searchButton,
        disabledColor: AppColors.searchButtonDis,
        disabledTextColor: AppColors.searchButtonDis,
      ),
      children: <Widget>[
        _buildAdvRow(context, 'Complete Local Name', result.advertisementData.localName),
        _buildAdvRow(context, 'Manufacturer Data', getNiceManufacturerData(result.advertisementData.manufacturerData)),
        _buildAdvRow(context, 'Service UUIDs', (result.advertisementData.serviceUuids.isNotEmpty) ? result.advertisementData.serviceUuids.join(', ').toUpperCase() : 'N/A'),
        _buildAdvRow(context, 'Service Data', getNiceServiceData(result.advertisementData.serviceData)),
      ],
    );
  }
}

class ServiceTile extends StatelessWidget{
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({Key? key, required this.service, required this.characteristicTiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(characteristicTiles.isNotEmpty){
      return ExpansionTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Service'),
              Text('0x${service.uuid.toString().toUpperCase().substring(4,8)}',
              style: Theme.of(context).textTheme.bodyText1?.copyWith(color: Theme.of(context).textTheme.caption?.color),),
            ],
          ),
          children: characteristicTiles,
      );
    }
    else{
      return ListTile(
        title: const Text('Service'),
        subtitle: Text('0x${service.uuid.toString().toUpperCase().substring(4, 8)}'),
      );
    }
  }
}

class CharacteristicTile extends StatelessWidget{

  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final Stream<BluetoothDeviceState> streamBluetoothDeviceState;
  /*final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;
  final VoidCallback? onNotificationPressed;*/

  const CharacteristicTile({Key? key, required this.characteristic,required this.descriptorTiles,required this.streamBluetoothDeviceState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int>>(
        stream: characteristic.value,
        initialData: characteristic.lastValue,
        builder: (context, snapshot){
          final value = snapshot.data;
          return ExpansionTile(
              title: ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Characteristic'),
                    Text('UUID : ${characteristic.uuid.toString().toUpperCase().substring(0)}',
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context).textTheme.caption?.color)),
                    Text('Notify : ${characteristic.properties.notify}'),
                    Text('WriteWithout : ${characteristic.properties.writeWithoutResponse}'),
                  ],
                ),
                contentPadding: const EdgeInsets.all(0.0),
              ),
              trailing: GFButton(
                  type: GFButtonType.outline,
                  text: 'SHOW CONSOLE',
                  onPressed: () => {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => TerminalScreen(characteristic: characteristic, deviceState: streamBluetoothDeviceState),)),
                    /*if(_checkDeviceConnected()){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TerminalScreen(characteristic: characteristic, deviceState: streamBluetoothDeviceState),)),
                    }
                    else{
                      AppAlert.showBottomToast(message: 'Device is disconnected. Please connect device...'),
                    }*/
                  }
              ),
              children: descriptorTiles,
          );
        }
    );
  }


}

class DescriptorTile extends StatelessWidget{

  final BluetoothDescriptor descriptor;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;

  const DescriptorTile({Key? key,required this.descriptor, this.onReadPressed, this.onWritePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text('0x${descriptor.uuid.toString().toUpperCase().substring(4,8)}', style: Theme.of(context).textTheme.bodyText1 ?.copyWith(color: Theme.of(context).textTheme.caption?.color),)
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (context, snapshot) {
          return Text(String.fromCharCodes(snapshot.data!));
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
              onPressed: onReadPressed,
              icon: Icon(Icons.file_download, color: Theme.of(context).iconTheme.color?.withOpacity(0.5),)
          ),
          IconButton(
              onPressed: onWritePressed,
              icon: Icon(Icons.file_upload, color: Theme.of(context).iconTheme.color?.withOpacity(0.5),)
          ),
        ],
      ),
    );
  }


}