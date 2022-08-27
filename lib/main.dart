import 'package:fire_client/DangerCard.dart';
import 'package:fire_client/Maps.dart';
import 'package:fire_client/SafeCard.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        notification_channel:
            IOWebSocketChannel.connect('ws://192.168.0.106:9999/ws'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final WebSocketChannel notification_channel;

  MyHomePage({
    Key key,
    @required this.title,
    @required this.notification_channel,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: widget.notification_channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<String> data = snapshot.data.split(",");

                  if (data[0] == 'fire') {
                    return Column(
                      children: <Widget>[
                        DangerCard(),
                        FloatingActionButton(
                          child: Icon(Icons.location_on),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  double.parse(data[1]),
                                  double.parse(data[2]),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        SafeCard(),
                        FloatingActionButton(
                          child: Icon(Icons.location_on),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapScreen(
                                  double.parse(data[1]),
                                  double.parse(data[2]),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    );
                  }
                } else
                  return SafeCard();
                /*return Center(
                      child: Text(snapshot.hasData ? '${snapshot.data}' : ''));*/
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.notification_channel.sink.close();
    super.dispose();
  }
}

class MapScreen extends StatelessWidget {
  double lat;
  double long;

  MapScreen(this.lat, this.long);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Fire_Map(lat, long),
    );
  }
}
