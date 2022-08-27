import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Fire_Map extends StatefulWidget {
  final double lat;
  final double long;
  Fire_Map(this.lat, this.long);

  @override
  State<Fire_Map> createState() => MapState(lat, long);
}

class MapState extends State<Fire_Map> {
  double lat;
  double long;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Completer<GoogleMapController> _controller = Completer();
  MapState(this.lat, this.long);
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        final String markerIdVal = '1';
        final MarkerId markerId = MarkerId(markerIdVal);
        final Marker marker =
            Marker(position: LatLng(lat, long), markerId: markerId);
        setState(() {
          markers[markerId] = marker;
        });
      },
      mapType: MapType.normal,
      markers: Set<Marker>.of(markers.values),
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, long),
        zoom: 15,
      ),
    );
  }
}
