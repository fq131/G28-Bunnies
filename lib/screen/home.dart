import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yumify/screen/list.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:yumify/utilities/localdb.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentAddress = "Loading location...";
  Position? _currentPosition;
  StreamController<int> selected = StreamController<int>();
  StreamController<List<String>> itemListStreamController =
      StreamController<List<String>>();
  var selectedItem;
  RestHelper restHelper = RestHelper();
  List<String> item = [" ", " ", " "];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getCurrentPosition();
      await _getName();
    });
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  Future<void> _getName() async {
    final data = await restHelper.getName();
    if (data.isNotEmpty && data.length > 1) {
      setState(() {
        item = data;
      });
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    Position? cachedPosition = await Geolocator.getLastKnownPosition();
    if (cachedPosition != null) {
      setState(() => _currentPosition = cachedPosition);
      _getAddressFromLatLng(cachedPosition);
    }

    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(position);
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = '${place.locality}, ${place.administrativeArea}';
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Current Location: ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _currentAddress,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _getCurrentPosition();
                        },
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ListPage()),
                          );
                        },
                        child: const Text(
                          "Build Your Own List",
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 400,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selected.add(
                      selectedItem = Random().nextInt(item.length),
                    );
                  });
                },
                child: Column(
                  children: [
                    Expanded(
                      child: FortuneWheel(
                        animateFirst: false,
                        items: [
                          for (var items in item)
                            FortuneItem(
                              child: Text(items),
                            )
                        ],
                        selected: selected.stream,
                        onAnimationEnd: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Selected Restaurant"),
                                content: Text(item[selectedItem]),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("OK"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        selected.add(
                                          selectedItem =
                                              Random().nextInt(item.length),
                                        );
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Spin Again"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical:
                              5.0), // Adjust the vertical spacing as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _getName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: Text(
                              "Update the Wheel Spin",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
