import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mled/tools/api_request.dart';
import 'package:mled/widgets/device_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<String> deviceList = <String>[];

  @override
  initState() {
    super.initState();
    _getIpAddress();
  }

  _getIpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //for dev
    setState(() {
      if (prefs.getStringList("deviceList") != null) {
        deviceList = prefs.getStringList("deviceList")!;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Device"),
        centerTitle: true,
      ),
      body: _buildListViewOfDevices());

  ListView _buildListViewOfDevices() {
    List<FutureBuilder> containers = <FutureBuilder>[];

    for (String device in deviceList) {
      containers.add(FutureBuilder<String>(
        future: getRequest(device + "/information"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var jsonData = snapshot.data.toString();
            var parsedJson = json.decode(jsonData);

            return DeviceCard(
              ipAddress: device,
              toggleState: parsedJson['toggleState'],
              brightness: parsedJson['brightness'],
              ledMode: parsedJson['ledMode'],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                children: const <Widget>[
                  SizedBox(
                    height: 250,
                  ),
                  SpinKitSpinningLines(
                    color: Colors.blue,
                    size: 100,
                    lineWidth: 5.0,
                    itemCount: 5,
                  ),
                ],
              ),
            );
          } else {
            return const Text("error");
          }
        },
      )

          // Container(child: DeviceCard(ipAddress: device))

          );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }
}
