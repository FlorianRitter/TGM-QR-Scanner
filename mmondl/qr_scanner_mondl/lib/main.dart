import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey qrKey = GlobalKey();
  var qrText;
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    //Vorgefertigte Abfrage vom Status der Camera-Permission
    Future status = PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    //Vorgefertigte Anforderung von der Camera-Permission
    Future<Map<PermissionGroup, PermissionStatus>> request = PermissionHandler().requestPermissions([PermissionGroup.camera]);
    //Ausführung der vorgefertigten Methoden
    status.then((status) {
      //Wenn die Anforderung nicht bereits angenommen wurde:
      if(status != PermissionStatus.granted){
        //: Soll die Anforderung gestellt werden
        request.then((request){
          //Wenn die Antwort des Benutzers "nicht zulassen" ist:
          if(request[PermissionGroup.camera] != PermissionStatus.granted){
            //TODO: Soll die "fehlende Permission"-Seite angezeigt werden
           Text(
             'Fehlende Kameraerlaubnis',
             style: TextStyle(fontSize: 32, color: Color.fromRGBO(66, 66, 66, 0.8)),
           );
           Text(
             'Erlaube QR-Scanner auf deine Kamera zuzugreifen. Du kannst diese Berechtigung unter Eistellung ändern.',
             style: TextStyle(fontSize: 12, color: Color.fromRGBO(117, 117, 117, 0.6)),
           );
          }
        });
      }
    });
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreate(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
      });
    });
  }
}
