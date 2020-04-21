import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(MyApp());

class YTRoute extends StatefulWidget {

  final String link;

  YTRoute({Key key, @required this.link}) : super(key: key);

  @override
  YTRouteState createState() => YTRouteState();
}

class YTRouteState extends State<YTRoute>{

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
        hideThumbnail: true,
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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var qrText = "";
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String status = "Press the button to determine the permission-Status";
  bool isPlayerReady = false;

  void askForPermission() async {
    String message = "";
    if (await Permission.camera.request().isGranted) {
      message = "Camera working!";
      //TODO: Show camera
    } else {
        Text txt1 = Text(
             'Fehlende Kameraerlaubnis',
             style: TextStyle(fontSize: 32, color: Color.fromRGBO(66, 66, 66, 0.8)),
           );
        Text txt2 = Text(
             'Erlaube QR-Scanner auf deine Kamera zuzugreifen. Du kannst diese Berechtigung unter Eistellung ändern.',
             style: TextStyle(fontSize: 12, color: Color.fromRGBO(117, 117, 117, 0.6)),
           );
        message = txt1.data + txt2.data;

    }
    setState(() {
      status = message;
    });
  }

  void openYoutube(String l) {
    if(!isPlayerReady){
      if(YoutubePlayer.convertUrlToId(l) != null){
        MaterialPageRoute route = MaterialPageRoute(builder: (context) => YTRoute(link: YoutubePlayer.convertUrlToId(l)));
        if(!route.isCurrent) {
          controller.pauseCamera();
          isPlayerReady = true;
          Navigator.push(context, route);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() {
    controller.resumeCamera();
    return super.didPopRoute();
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
                onQRViewCreated: _onQRViewCreate),
          )
        ],
      ),
    );
  }

  void _onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((onData) {
      qrText = onData;
      if(qrText != "") {
        openYoutube(qrText);
      }
    });
  }
}
