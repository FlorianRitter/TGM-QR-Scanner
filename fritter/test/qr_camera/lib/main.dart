import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(QRScanner());

class QRScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); //Test on iOS
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]); //Test on iOS
    return MaterialApp(
      home: QRCamera()
    );
  }
}

class QRCamera extends StatefulWidget {
  QRCamera({Key key}) : super(key: key);

  @override
  QRCameraState createState() => QRCameraState();
}

class QRCameraState extends State<QRCamera> {
  var qrText = "";
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isPlayerReady = false;
  bool isPermissioned = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            overlay: QrScannerOverlayShape(
              borderRadius: 0,
              borderColor: Colors.green,
              borderLength: 30,
              borderWidth: 5,
              cutOutSize: 300
            ),
            onQRViewCreated: onQRViewCreate,
          ),
          IconButton(
            icon: new Icon(Icons.info),
            iconSize: 35,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            onPressed: () => {
              //Impressum öffnen
            }
          )
        ]
      )
    );
  }

  void checkPermission() /*async*/ {
    // if (!await Permission.camera.isGranted) {
    //   isPermissioned = false;
    //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoPermission()));
    // }
    final Future<bool> permission = Permission.camera.isGranted;
    permission.then((isGranted) {
      if(!isGranted){
        isPermissioned = false;
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoPermission()));
      }
    });
  }

  void openYoutube(String link) {
    if(!isPlayerReady){
      if(YoutubePlayer.convertUrlToId(link) != null){
        MaterialPageRoute route = MaterialPageRoute(builder: (context) => Player(link: YoutubePlayer.convertUrlToId(link)));
        if(!route.isCurrent) {
          controller.pauseCamera();
          isPlayerReady = true;
          final navigation = Navigator.of(context).push(route);
          navigation.then((_) {
            controller.resumeCamera();
            isPlayerReady = false;
          });
        }
      }
    }
  }

  void onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((onData) {
      //  if(isPermissioned)
      //    checkPermission();
      qrText = onData;
      if(qrText != "") {
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
  YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
      initialVideoId: widget.link,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        enableCaption: false,
        controlsVisibleAtStart: true,
        hideThumbnail: false,
        hideControls: false,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ytKey,
      body: Column(
        children: <Widget>[
          Expanded (child:
            YoutubePlayer (
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
            )
          )
        ]
      )
    );
  }
}

class NoPermission extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Fehlende Kameraerlaubnis.',
                style: TextStyle(fontSize: 32, color: Color.fromRGBO(66, 66, 66, 0.8))
              ),
              Text(
                'Erlaube QR-Scanner auf deine Kamera zuzugreifen.\nDu kannst diese Berechtigung unter den Einstellung ändern.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color.fromRGBO(117, 117, 117, 0.6))
              )
            ],
          )
        ),
      ),
    );
  }
}