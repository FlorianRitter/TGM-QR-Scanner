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

  YoutubePlayerController player;
  YoutubePlayer view;

  void loadPlayer(BuildContext context){
    player = new YoutubePlayerController(initialVideoId: YoutubePlayer.convertUrlToId(widget.link));
    player.fitHeight(MediaQuery.of(context).size);
    view = YoutubePlayer(controller: player, progressColors: ProgressBarColors(playedColor: Colors.red, handleColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    loadPlayer(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
        Expanded(
          child: view
        ),
      ])
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

class _MyHomePageState extends State<MyHomePage> {
  var qrText = "";
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String status = "Press the button to determine the permission-Status";

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
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => YTRoute(link: l));
    if(!route.isCurrent) {
      Navigator.push(context, route);
      controller.pauseCamera();
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
