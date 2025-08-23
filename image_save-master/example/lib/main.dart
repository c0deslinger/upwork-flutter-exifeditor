import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_save/image_save.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = "";
  Uint8List? _data;
  Uint8List? _sandboxData;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    Response<List<int>> res = await Dio().get<List<int>>(
        "http://img.youai123.com/1507615921-5474.gif",
        options: Options(responseType: ResponseType.bytes));
    if (res.data != null) {
      _data = Uint8List.fromList(res.data!);
    }
  }

  Future<void> _saveImage() async {
    bool success = false;
    try {
      success =
          await ImageSave.saveImage(_data, "demo.gif", albumName: "demo") ??
              false;
    } on PlatformException catch (e, s) {
      print(e);
      print(s);
    }
    setState(() {
      _result = success ? "Save to album success" : "Save to album failed";
    });
  }

  Future<void> _saveImageToSandBox() async {
    bool success = false;
    try {
      success = await ImageSave.saveImageToSandbox(_data, "demo.gif") ?? false;
    } on PlatformException catch (e, s) {
      print(e);
      print(s);
    }
    setState(() {
      _result = success ? "Save to sandbox success" : "Save to sandbox failed";
    });
  }

  Future<void> _getImageFromSandBox() async {
    try {
      List<Uint8List>? files = await ImageSave.getImagesFromSandbox();
      if (files != null) {
        setState(() {
          _sandboxData = files[0];
        });
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Image.network('http://img.youai123.com/1507615921-5474.gif'),
                ElevatedButton(
                  onPressed: _saveImage,
                  child: const Text("Click to save to album"),
                ),
                ElevatedButton(
                  onPressed: _saveImageToSandBox,
                  child: const Text("Click to save to sandbox"),
                ),
                Text(_result),
                ElevatedButton(
                  onPressed: _getImageFromSandBox,
                  child: const Text("Get first image from sandbox"),
                ),
                _sandboxData != null
                    ? Image.memory(_sandboxData!)
                    : const Text("Please save image to sandbox first"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
