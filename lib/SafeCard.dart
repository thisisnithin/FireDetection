import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SafeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const ListTile(
              leading: Icon(Icons.cloud_circle),
              title: Text(
                'All good, nothing to report',
                style: TextStyle(fontSize: 24),
              ),
            ),
          )
        ],
      ),
    );
  }
}
