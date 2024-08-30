import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Marker? _userMarker;
  List<LatLng> _polylineCoordinates = [];
  Polyline? _polyline;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final CameraPosition _initialCameraPosition =
  CameraPosition(target: LatLng(0, 0), zoom: 14.0);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _userMarker = Marker(
        markerId: MarkerId('userMarker'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: 'My current location',
          snippet: '${position.latitude}, ${position.longitude}',
        ),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 14.0));
    });
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
        locationSettings:
        LocationSettings(accuracy: LocationAccuracy.high))
        .listen((Position position) {
      setState(() {
        _currentPosition = position;
        _polylineCoordinates.add(LatLng(position.latitude, position.longitude));
        _userMarker = Marker(
          markerId: MarkerId('userMarker'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: 'My current location',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        );
        _polyline = Polyline(
          polylineId: PolylineId('trackingPolyline'),
          points: _polylineCoordinates,
          color: Colors.blue,
          width: 5,
        );
        _mapController?.animateCamera(CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Map Animation'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _userMarker != null ? {_userMarker!} : {},
        polylines: _polyline != null ? {_polyline!} : {},
      ),
    );
  }
}
