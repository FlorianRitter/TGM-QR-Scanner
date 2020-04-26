import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(QRScanner());

class YTRoute extends StatefulWidget {

  final String link;

  YTRoute({Key key, @required this.link}) : super(key: key);

  @override
  YTRouteState createState() => YTRouteState();
}

class YTRouteState extends State<YTRoute> {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(debugLabel: "yt");
  YoutubePlayerController controller;
  YoutubeMetaData metaData;

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
      key: scaffoldKey,
      body: Column(
        children: <Widget>[
          Expanded (child:
            YoutubePlayer (
              topActions: <Widget>[
                BackButton()
              ],
              controller: controller,
              showVideoProgressIndicator: true,
              aspectRatio: 16 / 9,
              progressIndicatorColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class QRScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp
    ]);
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

  void checkPermission() async {
    if (await Permission.camera.request().isGranted) {
      message = "Camera working!";
      //TODO: Show camera
    }
    else{
    
       message= "Fehlende Kameraerlaubnis\nErlaube QR-Scanner auf deine Kamera zuzugreifen. Du kannst diese Berechtigung unter Eistellung ändern.";
        
     
    }
    setState(() {
      status = message;
    });
  }

  void openYoutube(String link) {
    if(!isPlayerReady){
      if(YoutubePlayer.convertUrlToId(link) != null){
        MaterialPageRoute route = MaterialPageRoute(builder: (context) => YTRoute(link: YoutubePlayer.convertUrlToId(link)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              overlay: QrScannerOverlayShape(
                borderRadius: 0,
                borderColor: Colors.green,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: 300),
              onQRViewCreated: onQRViewCreate
            ),
          )
        ],
      ),
    );
  }

  void onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((onData) {
      qrText = onData;
      if(qrText != "") {
        openYoutube(qrText);
      }
    });
  }
}
