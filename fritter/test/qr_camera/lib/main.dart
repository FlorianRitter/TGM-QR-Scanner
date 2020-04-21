import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() => runApp(MyApp());

class YTRoute extends StatefulWidget {

  final String link;
  final QRViewController qrController;

  YTRoute({Key key, @required this.link, @required this.qrController}) : super(key: key);

  @override
  YTRouteState createState() => YTRouteState();
}

class YTRouteState extends State<YTRoute> with WidgetsBindingObserver {

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(debugLabel: "yt");
  YoutubePlayerController controller;
  YoutubeMetaData metaData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      message = "Camera not working!";
      //TODO: show no camera permission granted screen
    }
    setState(() {
      status = message;
    });
  }

  void openYoutube(String l) {
    if(!isPlayerReady){
      if(YoutubePlayer.convertUrlToId(l) != null){
        MaterialPageRoute route = MaterialPageRoute(builder: (context) => YTRoute(link: YoutubePlayer.convertUrlToId(l), qrController: controller));
        if(!route.isCurrent) {
          controller.pauseCamera();
          isPlayerReady = true;
          Navigator.of(context).push(route);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("################################################## " + state.index.toString());
    if(state == AppLifecycleState.resumed) {
      controller.resumeCamera();
      isPlayerReady = false;
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
              onQRViewCreated: _onQRViewCreate
            ),
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
