import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DangerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.redAccent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: const ListTile(
              leading: Icon(Icons.error),
              title: Text(
                'Fire Detected !',
                style: TextStyle(fontSize: 24),
              ),
            ),
          )
        ],
      ),
    );
  }
}
