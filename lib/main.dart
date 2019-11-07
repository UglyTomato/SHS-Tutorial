import 'dart:async';
import 'package:qr_scanner/info.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  TextEditingController FirstName = new TextEditingController();
  TextEditingController LastName = new TextEditingController();
  final DatabaseReference database = FirebaseDatabase.instance.reference();
  String numEntries = "blah";
  GoogleSignIn  _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool _isLoggedIn = false;

  void initState(){
    super.initState();
    if(_isLoggedIn){
      result = "Tap me to sign in!";
    } else {
      result = "Log in with your School Google account to continue.";
    }
  }

  _login() async{
    try{
      await _googleSignIn.signIn();
      if(_googleSignIn.currentUser.email.split('@')[1] == "lgsstudent.org"){
        setState(() {
          _isLoggedIn = true;
          result = "Tap me to sign in!";
  //        result = _googleSignIn.currentUser.displayName;
        });
      } else {
        _logout();
      }
    }
    catch(err){
      print(err);
    }
  }
  _logout() {
    _googleSignIn.signOut();
    setState(() {
      _isLoggedIn = false;
      result = "Log in with your School Google account to continue.";
//      result = "Log in!";
    });
  }

//  _launchURL( String result) async {
////    const url = result;
//    if (await canLaunch(result)) {
//      await launch(result);
//    } else {
//      throw 'Could not launch $result';
//    }
//  }

  void writeData(String s, String id, String firstName, String lastName, String qrResult, String condition){
    var now = new DateTime.now();
    print(now.month.toString() + "/" + now.day.toString() + "/" + now.year.toString() + " " + DateFormat("H:m:s").format(now));
    database.child(s).set({
      'Timestamp': (now.month.toString() + "/" + now.day.toString() + "/" + now.year.toString() + " " + DateFormat("H:m:s").format(now)),
      'Student ID': id,
      'First Name': firstName,
      'Last Name': lastName,
      'Room Number': qrResult,
      'Contition': condition,
    });
  }
  void readNumEntries(){
    database.child('numEntries').once().then((DataSnapshot snapshot) {
//      return snapshot.value;
      print('Data : ${snapshot.value}');
      numEntries = snapshot.value.toString();
    });
  }
  
  
  Future _scanQR() async {
    print("yolo");
    setState(() {
      readNumEntries();
    });

    String id = "";
    for(int x = 0; x < _googleSignIn.currentUser.email.length-1; x++){
      String email = _googleSignIn.currentUser.email;
      if(email.substring(x, x+1) == "1" || email.substring(x, x+1) == "2" || email.substring(x, x+1) == "3" || email.substring(x, x+1) == "4" || email.substring(x, x+1) == "5" || email.substring(x, x+1) == "6" || email.substring(x, x+1) == "7" || email.substring(x, x+1) == "8" || email.substring(x, x+1) == "9" || email.substring(x, x+1) == "0"){
        id += email.substring(x, x+1);
      }
    }
    id = "11" + id;
    String firstName = _googleSignIn.currentUser.displayName.split(" ")[0];
    String lastName = _googleSignIn.currentUser.displayName.split(" ")[1];
    print(id);
    print(firstName);
    print(lastName);

    try {
      LastRoom room = new LastRoom();
//      room.writeContent("hi1!!!!");
      String qrResult = await BarcodeScanner.scan();
      String condition = "";
      room.readContent().then((onValue){
        if(onValue == "Check in"){
          condition = "Check Out";
        } else {
          condition = "Check in";
        }
        writeData((int.parse(numEntries) + 1).toString(), id, firstName, lastName, qrResult, condition);
        room.writeContent(condition);

        setState(() {
//        result = "https://docs.google.com/forms/d/e/1FAIpQLSeX5jxY2oSHea8C2VCmEEj7ZFYG7F7KuPRrX9QHUbXwBIdt_A/viewform?usp=pp_url&entry.693612192=$firstName&entry.1310158676=$lastName&entry.201368718=$id&entry.503158018=$qrResult";
//        result = "https://docs.google.com/forms/d/e/1FAIpQLSeX5jxY2oSHea8C2VCmEEj7ZFYG7F7KuPRrX9QHUbXwBIdt_A/viewform?usp=pp_url&entry.201368718=$id&entry.503158018=$qrResult";
//        _launchURL(result);
          result = "All checked in!\nTap again to check in!";


          database.update({
            'numEntries': (int.parse(numEntries) + 1).toString()
          });
        });



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
        result = "Tap me to sign in!";
      });
    } catch (ex) {
      setState(() {
//        result = "Unknown Error $ex";
      });
    }
  }
  Future _DoNothing() async {

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

          _isLoggedIn?
          Row(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Image.network(
                  _googleSignIn.currentUser.photoUrl,
                  height: 80,
                  width: 80,
                )
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    Text(_googleSignIn.currentUser.displayName, style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                    Container(
                      height: 50,
                      width: 150,
                      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                      decoration: new BoxDecoration(
                        borderRadius: new BorderRadius.only(
                          topLeft: const Radius.circular(20.0),
                          topRight: const Radius.circular(20.0),
                          bottomLeft: const Radius.circular(20.0),
                          bottomRight: const Radius.circular(20.0),
                        ),
                        color: Colors.grey[300],
                      ),
                      child: InkWell(
                          onTap: _logout,
                          child: Center(
                            child: Text("Log Out?", style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                          )
                      ),
                    )
                  ],
                )
              )


            ],
          ) : Row(
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Icon(Icons.account_circle, size: 80,)
              ),
              Container(
                height: 100,
                width: 150,
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(20.0),
                    topRight: const Radius.circular(20.0),
                    bottomLeft: const Radius.circular(20.0),
                    bottomRight: const Radius.circular(20.0),
                  ),
                  color: Colors.grey[300],
                ),
                child: InkWell(
                  onTap: _login,
                  child: Center(
                    child: Text("Log In?", style: new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                  )
                ),
              )

            ],
          ),
//          Container(
//            padding: EdgeInsets.all(5),
//            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
////          width: MediaQuery.of(context).size.width-30,
//            decoration: new BoxDecoration(
////            border: new Border.all(color: Colors.black, width: 0.5),
//              borderRadius: new BorderRadius.only(
//                topLeft: const Radius.circular(5.0),
//                topRight: const Radius.circular(5.0),
//                bottomLeft: const Radius.circular(5.0),
//                bottomRight: const Radius.circular(5.0),
//              ),
//              color: Colors.grey[300],
//            ),
//            width: MediaQuery.of(context).size.width,
//            child: Center(
//              child: TextField(
//                controller: FirstName,
//                decoration: new InputDecoration(labelText: "First Name"),
//                keyboardType: TextInputType.text,
//              ),
//            ),
//          ),
//          Container(
//            padding: EdgeInsets.all(5),
//            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
////          width: MediaQuery.of(context).size.width-30,
//            decoration: new BoxDecoration(
////            border: new Border.all(color: Colors.black, width: 0.5),
//              borderRadius: new BorderRadius.only(
//                topLeft: const Radius.circular(5.0),
//                topRight: const Radius.circular(5.0),
//                bottomLeft: const Radius.circular(5.0),
//                bottomRight: const Radius.circular(5.0),
//              ),
//              color: Colors.grey[300],
//            ),
//            width: MediaQuery.of(context).size.width,
//            child: Center(
//              child: TextField(
//                controller: LastName,
//                decoration: new InputDecoration(labelText: "Last Name"),
//                keyboardType: TextInputType.text,
//              ),
//            ),
//          ),
//          Container(
//            padding: EdgeInsets.all(5),
//            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
////          width: MediaQuery.of(context).size.width-30,
//            decoration: new BoxDecoration(
////            border: new Border.all(color: Colors.black, width: 0.5),
//              borderRadius: new BorderRadius.only(
//                topLeft: const Radius.circular(5.0),
//                topRight: const Radius.circular(5.0),
//                bottomLeft: const Radius.circular(5.0),
//                bottomRight: const Radius.circular(5.0),
//              ),
//              color: Colors.grey[300],
//            ),
//            width: MediaQuery.of(context).size.width,
//            child: Center(
//              child: TextField(
//                controller: studID,
//                decoration: new InputDecoration(labelText: "Enter your ID"),
//                keyboardType: TextInputType.number,
//              ),
//            ),
//          ),


          InkWell(
            onTap: () {
              _isLoggedIn?
              _scanQR():
              print("Log in!!")
              ;
            },
//              _scanQR,
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