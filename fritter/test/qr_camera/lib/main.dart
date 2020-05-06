import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() => runApp(QRScanner());

class QRScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(home: CameraPermission());
  }
}

class CameraPermission extends StatefulWidget {
  @override
  CameraPermissionState createState() => CameraPermissionState();
}

class CameraPermissionState extends State<CameraPermission> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  @override
  void initState() {
    //Firebase appstart
    checkPermission();
    super.initState();
  }

  void checkPermission() async {
    MaterialPageRoute route;
    if (!await Permission.camera.request().isGranted) {
      route = MaterialPageRoute(builder: (context) => NoPermission());
    } else
      route = MaterialPageRoute(builder: (context) => QRCamera());
    final navigation = Navigator.of(context).push(route);
    navigation.then((_) {
      if (Platform.isAndroid)
        SystemNavigator.pop();
      else
        exit(0);
    });
  }
}

class QRCamera extends StatefulWidget {
  QRCamera({Key key}) : super(key: key);

  @override
  QRCameraState createState() => QRCameraState();
}

class QRCameraState extends State<QRCamera> {
  String qrText = "";
  String previousLink = "";
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isPlayerReady = false;
  MediaQueryData queryData;

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    return Scaffold(
        body: Stack(children: <Widget>[
      QRView(
        key: qrKey,
        overlay: QrScannerOverlayShape(
            borderRadius: 0,
            borderColor: Colors.green,
            borderLength: 30,
            borderWidth: 5,
            cutOutSize: 300),
        onQRViewCreated: onQRViewCreate,
      ),
      IconButton(
          icon: new Icon(Icons.info),
          iconSize: 35,
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          onPressed: () => {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => WebView()))
              }),
      Container(
          color: Colors.red,
          margin: EdgeInsets.only(
              top: 0.8 * queryData.size.height,
              left: 0.1 * queryData.size.width),
          height: 60,
          width: 0.8 * queryData.size.width,
          padding: new EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Text("Scanne den QR-Code aus dem Katalog",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white)))
    ]));
  }

  void openYoutube(String link) {
    String l = link;
    if (!isPlayerReady && previousLink != link) {
      if (yt.YoutubePlayer.convertUrlToId(link) != null) {
        l = "";
        //Firebase success
        //Firebase video
        MaterialPageRoute route = MaterialPageRoute(
            builder: (context) =>
                Player(link: yt.YoutubePlayer.convertUrlToId(link)));
        if (!route.isCurrent) {
          controller.pauseCamera();
          isPlayerReady = true;
          final navigation = Navigator.of(context).push(route);
          navigation.then((_) {
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.portraitUp]);
            controller.resumeCamera();
            isPlayerReady = false;
          });
        }
      } else {
        //Firebase success
        //Firebase faulty
      }
    }
    previousLink = l;
  }

  void onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((onData) {
      qrText = onData;
      if (qrText != "") {
        openYoutube(qrText);
      }
    });
  }
}

class Player extends StatefulWidget {
  final String link;

  Player({Key key, @required this.link}) : super(key: key);

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> {
  final GlobalKey ytKey = GlobalKey(debugLabel: "YT");
  yt.YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = yt.YoutubePlayerController(
        initialVideoId: widget.link,
        flags: yt.YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
          disableDragSeek: true,
          loop: false,
          isLive: false,
          enableCaption: false,
          controlsVisibleAtStart: true,
          hideThumbnail: false,
          hideControls: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: ytKey,
        body: Column(children: <Widget>[
          Expanded(
              child: yt.YoutubePlayer(
            topActions: <Widget>[
              IconButton(
                icon: new Icon(Icons.arrow_back),
                iconSize: 35,
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ],
            controller: controller,
            showVideoProgressIndicator: true,
            aspectRatio: 16 / 9,
            progressIndicatorColor: Colors.red,
          ))
        ]));
  }
}

class NoPermission extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
          Text('Fehlende Kameraerlaubnis.',
              style: TextStyle(
                  fontSize: 32, color: Color.fromRGBO(66, 66, 66, 0.8))),
          Text(
              'Erlaube QR-Scanner auf deine Kamera zuzugreifen.\nDu kannst diese Berechtigung unter den Einstellung ändern.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Color.fromRGBO(117, 117, 117, 0.6)))
        ])));
  }
}

class WebView extends StatefulWidget {
  @override
  WebViewState createState() => WebViewState();
}

class WebViewState extends State<WebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (BuildContext context) {
      return yt.WebView(
          initialUrl: "https://www.allaboutapps.at/impressum/",
          javascriptMode: yt.JavascriptMode.unrestricted,
          gestureNavigationEnabled: true);
    }));
  }
}
