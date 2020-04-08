import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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

  String status = "Press the button to determine the permission-Status";

  void askForPermission() async {
    String message = "";
    if(await Permission.camera.request().isGranted){
      message = "Camera working!";
      //TODO: Show camera
    }
    else{
      message = "Camera not working!";  
      //TODO: show no camera permission granted screen
    }
    setState(() {
      status = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$status',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: askForPermission,
        tooltip: 'Permission',
        child: Icon(Icons.perm_camera_mic),
      ),
    );
  }
}
