import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:place_picker/place_picker.dart';
import 'package:zoptalassignment/profile.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng initpos;
  late CameraPosition initialCameraPostion;
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "";

  late LocationData currentLocation;

  late double desLatitude;
  late double desLong;
  late Location loca;
  double CAMERA_ZOOM = 19.151926040649414;
  double CAMERA_TILT = 59.440717697143555;
  double CAMERA_BEARING = 192.8334901395799;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    getInitLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Profile()));
            },
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  clearCor();
                  showPlacePicker();
                },
                icon: const Icon(Icons.search))
          ]),
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: Set<Polyline>.of(polylines.values),
              mapType: MapType.normal,
              initialCameraPosition: initialCameraPostion,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);

                showPinsOnMap();
              },
              onTap: (v) async {
                desLatitude = v.latitude;
                desLong = v.longitude;
                clearCor();
                await showPinsOnMap();
              },
            ),
    );
  }

  getInitLocation() async {
    Location location = Location();
    LocationData _locationData = await location.getLocation();
    initpos =
        LatLng(_locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0);
    initialCameraPostion = CameraPosition(
        bearing: CAMERA_BEARING,
        target: initpos,
        tilt: CAMERA_TILT,
        zoom: CAMERA_ZOOM);

    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      updatePinOnMap();
    });

    setState(() {
      isloading = false;
    });
  }

   showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
              googleAPIKey,
              displayLocation: initpos,
            )));

    desLatitude = result.latLng!.latitude;
    desLong = result.latLng!.longitude;
    setState(() {
      showPinsOnMap();
    });
  }

  showPinsOnMap() async {
    var pinPosition = LatLng(
        currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0);
    var destPosition = LatLng(desLatitude, desLong);
    _markers.add(Marker(
      markerId: const MarkerId('sourcePin'),
      position: pinPosition,
    ));

    _markers.add(Marker(
        markerId: const MarkerId('destPin'),
        position: destPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(90)));
    await setPolylines();
  }

  updatePinOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(
          currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

    setState(() {
      var pinPosition = LatLng(
          currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0);

      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
        markerId: const MarkerId('sourcePin'),
        position: pinPosition,
      ));
    });
  }

  setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(
          currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0),
      PointLatLng(desLatitude, desLong),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      PolylineId id = const PolylineId("poly");
      Polyline polyline = Polyline(
          polylineId: id, color: Colors.red, points: polylineCoordinates);
      polylines[id] = polyline;
      setState(() {});
    
    }
  }

  clearCor() {
    polylineCoordinates.clear();
    polylines.clear();
  }
}
