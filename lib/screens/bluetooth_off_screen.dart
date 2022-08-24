import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_ft/screens/widgets/app_loader.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/constants/styles/styles.dart';

class BluetoothOffScreen extends StatefulWidget {
  final BluetoothState? state;

  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BluetoothOffScreenState();
  }
}

class _BluetoothOffScreenState extends State<BluetoothOffScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  PackageInfo _packageInfo = PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown');

  @override
  void initState() {
    super.initState();
    initDatas();
  }

  Future<void> initDatas() async {
    await initPackageInfo();
    await initPlatformState();
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidDeviceInfo(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIOSDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{'Error': 'Failed to get platform version'};
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidDeviceInfo(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIOSDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: Future.wait([initPackageInfo(), initPlatformState()]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SafeArea(
                  child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.bluetooth),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                            'Bluetooth Adapter is ${widget.state != null ? widget.state.toString().substring(15).toUpperCase() : 'not available'}.',
                            style: AppStyle.textBody1),
                        Platform.isAndroid
                            ? GFButton(
                                onPressed: () =>
                                    FlutterBluePlus.instance.turnOn(),
                                type: GFButtonType.outline2x,
                                child: const Text('TURN ON'),
                              )
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InfoRow(
                        name: "Platform is ",
                        value: Platform.isAndroid
                            ? 'Android Device Info'
                            : Platform.isIOS
                                ? 'iOS Device Info'
                                : Platform.isMacOS
                                    ? 'MacOS Device Info'
                                    : Platform.isWindows
                                        ? 'Windows Device Info'
                                        : 'Unknown'),
                    InfoRow(
                        name: 'Application name',
                        value: _packageInfo.appName.toUpperCase()),
                    InfoRow(
                        name: 'Build number',
                        value: _packageInfo.buildNumber.toUpperCase()),
                    InfoRow(name: 'Version', value: _packageInfo.version),
                    const SizedBox(
                      height: 20,
                    ),

/*  ListView(
                      children: _deviceData.keys.map((String property){
                        return Container(
                          height: 100,
                          child: Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(property, style: AppStyle.textBody1),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),*/
                  ],
                ),
              ));
            } else {
              return const AppLoader();
            }
          },
        ));
  }
}

class InfoRow extends StatelessWidget {
  final String name;
  final String value;

  const InfoRow({Key? key, required this.name, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(name, style: AppStyle.textBody1),
        Text(value.toUpperCase(), style: AppStyle.textBody2, softWrap: true),
      ],
    );
  }
}
