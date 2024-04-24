import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yumify/utilities/location_service.dart';

class LocationPage extends StatefulWidget {
  @override
  State<LocationPage> createState() => LocationPageState();
}

class LocationPageState extends State<LocationPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  Position? locationData;
  bool _locationFetched = false;

  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  TextEditingController _autocompleteController = TextEditingController();
  List<String> _restaurantSuggestions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationFetched) {
      _locationFetched = true; // Mark location as fetched
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          locationData = position;
        });
        LatLng currentPosition = LatLng(
          locationData!.latitude,
          locationData!.longitude,
        );
        _setMarker(currentPosition);
        _goToPlace(currentPosition);
      } catch (e) {
        debugPrint('Error fetching location: $e');
      }
    }
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker'),
          position: point,
        ),
      );
    });
  }

  Future<void> _goToPlace(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14),
      ),
    );
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 4,
        color: Colors.red,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  Future<void> _fetchRestaurantSuggestions(String input) async {
    if (input.isNotEmpty) {
      try {
        List<String> suggestions =
            await LocationService().getRestaurantSuggestions(input);
        setState(() {
          _restaurantSuggestions = suggestions;
        });
      } catch (e) {
        debugPrint('Error fetching restaurant suggestions: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Google Maps',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          TextFormField(
            controller: _autocompleteController,
            decoration: InputDecoration(hintText: 'Search Restaurant'),
            onChanged: (value) {
              _fetchRestaurantSuggestions(value);
            },
          ),
          if (_autocompleteController.text.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _restaurantSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_restaurantSuggestions[index]),
                    onTap: () {
                      _autocompleteController.text =
                          _restaurantSuggestions[index];
                    },
                  );
                },
              ),
            ),
          IconButton(
            onPressed: () async {
              if (locationData != null) {
                var directions = await LocationService().getDirections(
                  '${locationData!.latitude},${locationData!.longitude}',
                  _autocompleteController.text,
                );
                if (directions['polyline_decoded'] != null) {
                  setState(() {
                    _polylines.clear();
                    _setPolyline(directions['polyline_decoded']);
                    _autocompleteController.clear();
                    _restaurantSuggestions.clear();
                  });
                  _goToPlace(
                    LatLng(
                      locationData!.latitude,
                      locationData!.longitude,
                    ),
                  );
                } else {
                  debugPrint('Invalid directions data');
                }
              } else {
                debugPrint('Location data not available');
              }
            },
            icon: Icon(Icons.search),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0), // Initial camera position
                zoom: 2,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}
