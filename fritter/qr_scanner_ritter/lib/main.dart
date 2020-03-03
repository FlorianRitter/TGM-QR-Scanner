import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
          }
        });
      }
    });
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
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
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
