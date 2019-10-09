import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: HomePage(),
));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String result = "Hey there !";

  _launchURL( String result) async {
//    const url = result;
    if (await canLaunch(result)) {
      await launch(result);
    } else {
      throw 'Could not launch $result';
    }
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {

        result = "https://docs.google.com/forms/d/e/1FAIpQLSeX5jxY2oSHea8C2VCmEEj7ZFYG7F7KuPRrX9QHUbXwBIdt_A/viewform?usp=pp_url&entry.201368718=111111&entry.503158018=$qrResult";
        _launchURL(result);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanner"),
      ),
      body: Center(
        child: Text(
          result,
          style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}