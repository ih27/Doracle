import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../config/theme.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapOverlay extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;

  const MapOverlay({super.key, required this.onLocationSelected});

  @override
  _MapOverlayState createState() => _MapOverlayState();
}

class _MapOverlayState extends State<MapOverlay> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng? selectedLocation;
  String selectedAddress = '';

  final LatLng _center = const LatLng(41.0082, 28.9784); // Istanbul coordinates

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          selectedAddress = '${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      setState(() {
        selectedAddress = 'Location not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GooglePlacesAutoCompleteTextFormField(
                    textEditingController: _searchController,
                    googleAPIKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
                    isLatLngRequired: true,
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      if (prediction.lat != null && prediction.lng != null) {
                        double? lat = double.tryParse(prediction.lat!);
                        double? lng = double.tryParse(prediction.lng!);
                        if (lat != null && lng != null) {
                          LatLng newLocation = LatLng(lat, lng);
                          setState(() {
                            selectedLocation = newLocation;
                          });
                          mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(newLocation, 14.0));
                          _getAddressFromLatLng(newLocation);
                        }
                      }
                    },
                    itmClick: (Prediction prediction) {
                      _searchController.text = prediction.description!;
                      _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length));
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for a place',
                      border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppTheme.primaryColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 11.0,
                    ),
                    onTap: (LatLng latLng) {
                      setState(() {
                        selectedLocation = latLng;
                      });
                      _getAddressFromLatLng(latLng);
                    },
                    markers: selectedLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId('selected_location'),
                              position: selectedLocation!,
                            ),
                          }
                        : {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    selectedAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).textTheme.titleSmall?.color,
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.3, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.info,
                                    letterSpacing: 0,
                                  ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedLocation != null) {
                            widget.onLocationSelected(
                                selectedLocation!, selectedAddress);
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please select a location')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).textTheme.titleSmall?.color,
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.3, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.info,
                                    letterSpacing: 0,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
