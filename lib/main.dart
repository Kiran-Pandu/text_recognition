import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/label_detect.dart';
import 'package:flutter_application_1/navigation_drawer.dart';
import 'package:flutter_application_1/select_image.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlkit/mlkit.dart';

import 'customBrowser.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(duration: 4, goToPage: HomePage())));
}

class SplashPage extends StatelessWidget {
  static int numOfVisits = 0;
  static bool isLoggedIn = false;
  int duration = 0;
  Widget goToPage;
  SplashPage({required this.goToPage, required this.duration});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: this.duration), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => this.goToPage));
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
            body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: new AssetImage("gifFinal.gif"), fit: BoxFit.cover)),
          child: Container(
              color: Color(0xFF181818),
              child: Center(child: Image.asset('assets/icons8_camera_96.png'))),
        )),
      ),
    );
  }
}

enum ImageSourceType { gallery, camera }

class HomePage extends StatelessWidget {
  FirebaseVisionLabelDetector labelDetector =
      FirebaseVisionLabelDetector.instance;
  void _handleURLButtonPress(BuildContext context, var type) {
    final imagePicker = ImagePicker();
    XFile file;
    File useFile;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ImageFromGalleryEx(type)));
  }

  @override
  Widget build(BuildContext context) {
    var widthScreen = MediaQuery.of(context).size.width;
    var heightScreen = MediaQuery.of(context).size.height;

    BoxDecoration myBoxDecoration() {
      return BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Color(0xFF505050),
          width: 1.0,
        )),
      );
    }

    return WillPopScope(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: new AssetImage("gifFinal.gif"), fit: BoxFit.cover)),
          height: heightScreen,
          width: widthScreen,
          child: Padding(
            padding: EdgeInsets.only(
                top: 0, left: widthScreen / 50, right: widthScreen / 50),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: Color(0xFF6305dc),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0),
                      side: BorderSide(width: 5, color: Color(0xFF212121)),
                    ),
                    padding: EdgeInsets.only(
                        left: widthScreen / 8,
                        right: widthScreen / 8,
                        top: heightScreen / 8,
                        bottom: heightScreen / 8),
                    child: Text(
                      "Pick Image\nfrom Gallery",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gilroy',
                          fontSize: 21),
                    ),
                    onPressed: () {
                      _handleURLButtonPress(context, ImageSourceType.gallery);
                    },
                  ),
                  Container(
                    child: SizedBox(width: widthScreen / 2, height: 25),
                    decoration: myBoxDecoration(),
                  ),
                  Container(
                    child: SizedBox(width: 50, height: 25),
                  ),
                  MaterialButton(
                    color: Color(0xFF6305dc),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0),
                      side: BorderSide(
                        width: 5,
                        color: Color(0xFF212121),
                      ),
                    ),
                    padding: EdgeInsets.only(
                        left: widthScreen / 8,
                        right: widthScreen / 8,
                        top: heightScreen / 8,
                        bottom: heightScreen / 8),
                    child: Text(
                      "Pick Image\nfrom Camera",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gilroy',
                          fontSize: 20.75),
                    ),
                    onPressed: () {
                      _handleURLButtonPress(context, ImageSourceType.camera);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        drawer: SideDrawer(),
        appBar: AppBar(
            title:
                Text("Image Picker ", style: TextStyle(fontFamily: 'Gilroy')),
            backgroundColor: Color(0xFF6305dc),
            centerTitle: true,
            actions: [
              new IconButton(
                icon: new Icon(Icons.arrow_back, color: Color(0xFF6305dc)),
                onPressed: () => onWillPop(context),
              )
            ]),
      ),
      onWillPop: () => onWillPop(context),
    );
  }

  Future<bool> onWillPop(context) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: Color(0xFF6305dc),
        title: new Text('Confirm Exit?',
            style: new TextStyle(
                color: Colors.white, fontSize: 22.0, fontFamily: 'Gilroy')),
        content: new Text(
          'Are you sure you want to exit the app?',
          style: TextStyle(
              color: Colors.white, fontSize: 18.0, fontFamily: 'Gilroy'),
        ),
        actions: <Widget>[
          Center(
            child: Column(
              children: [
                (SplashPage.isLoggedIn)
                    ? new MaterialButton(
                        color: Color(0xFF212121),
                        onPressed: () {
                          SplashPage.isLoggedIn = false;
                          String url =
                              'https://www.amazon.in/gp/flex/sign-out.html?path=%2Fgp%2Fyourstore%2Fhome&signIn=1&useRedirectOnSuccess=1&action=sign-out&ref_=nav_AccountFlyout_signout';
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CustomBrowser(url, ' ')));
                        },
                        child: new Text('Logout from Amazon',
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontFamily: 'Gilroy')),
                      )
                    : Divider(),
                new MaterialButton(
                  color: Color(0xFF212121),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: new Text(
                      (SplashPage.isLoggedIn) ? 'Exit anyway' : 'Yes',
                      style: new TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: 'Gilroy')),
                ),
              ],
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
