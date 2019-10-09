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
  String result = "Tap me to sign in!";
  TextEditingController studID = new TextEditingController();

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
      String id = studID.text;
      setState(() {
        result = "https://docs.google.com/forms/d/e/1FAIpQLSeX5jxY2oSHea8C2VCmEEj7ZFYG7F7KuPRrX9QHUbXwBIdt_A/viewform?usp=pp_url&entry.201368718=$id&entry.503158018=$qrResult";
        _launchURL(result);
        result = "All checked in!\nTap again to check in!";
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
//          result = "Camera permission was denied";
        });
      } else {
        setState(() {
//          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
//        result = "Unknown Error $ex";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text("QR Scanner"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
//          width: MediaQuery.of(context).size.width-30,
            decoration: new BoxDecoration(
//            border: new Border.all(color: Colors.black, width: 0.5),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(5.0),
                topRight: const Radius.circular(5.0),
                bottomLeft: const Radius.circular(5.0),
                bottomRight: const Radius.circular(5.0),
              ),
              color: Colors.grey[300],
            ),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: TextField(
                controller: studID,
                decoration: new InputDecoration(labelText: "Enter your ID"),
                keyboardType: TextInputType.number,
              ),
            ),
          ),

          InkWell(
            onTap: _scanQR,
            child: Container(
              padding: EdgeInsets.all(5),
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
//          width: MediaQuery.of(context).size.width-30,
              decoration: new BoxDecoration(
//            border: new Border.all(color: Colors.black, width: 0.5),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(5.0),
                  topRight: const Radius.circular(5.0),
                  bottomLeft: const Radius.circular(5.0),
                  bottomRight: const Radius.circular(5.0),
                ),
                color: Colors.grey[300],
              ),
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Center(
                child: Text(
                  result,
                  style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
              )
            )
          )
        ],
      ),
      backgroundColor: Colors.grey,
    );
  }
}
