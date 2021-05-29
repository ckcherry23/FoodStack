import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodstack/providers/userLocator.dart';
import 'package:foodstack/services/geocoderService.dart';
import 'package:foodstack/src/themeColors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodstack/src/widgets/header.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  Widget build(BuildContext context) {
    final userLocator = Provider.of<UserLocator>(context);
    final geocoderService = GeocoderService();
    LatLng userCoordinates = userLocator.coordinates;
    geocoderService.getCameraLocation(userCoordinates);
    GoogleMapController _mapController;

    void whenMapCreated(GoogleMapController _controller) {
      setState(() {
        _mapController = _controller;
      });
    }

    return Scaffold(
        appBar: Header.getAppBar(title: 'Add delivery address'),
        body: (userLocator.currentLocation == null)
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, bottom: 30.0),
                child: Column(
                  children: [
                    CupertinoSearchTextField(
                      padding: EdgeInsets.all(15.0),
                    ),
                    SizedBox(height: 30.0),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            child: GoogleMap(
                                mapType: MapType.normal,
                                zoomControlsEnabled: false,
                                minMaxZoomPreference:
                                    MinMaxZoomPreference(1.5, 21),
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                mapToolbarEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: userCoordinates,
                                  zoom: 14,
                                ),
                                onCameraMove: (CameraPosition cameraPosition) {
                                  userLocator.onCameraMove(cameraPosition);
                                },
                                onMapCreated: whenMapCreated,
                                onCameraIdle: () {
                                  geocoderService
                                      .getCameraLocation(userCoordinates);
                                }),
                          ),
                          Center(
                            child: Container(
                              height: 500,
                              child: Icon(
                                Icons.location_pin,
                                color: ThemeColors.oranges,
                                size: 50.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   height: 200.0,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(30.0),
                    //     child: Column(
                    //       children: [
                    //         Text(geocoderService.deliveryAddress.featureName),
                    //         Text(geocoderService.deliveryAddress.addressLine),
                    //       ],
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ));
  }
}