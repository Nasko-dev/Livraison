import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'mission_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LocationData? _currentLocation;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        _currentLocation = locationData;
      });
      _addDeliveryMarkers();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _addDeliveryMarkers() {
    if (_currentLocation == null) return;

    // Exemple de points de livraison (à remplacer par vos données réelles)
    final deliveryPoints = [
      LatLng(_currentLocation!.latitude! + 0.01,
          _currentLocation!.longitude! + 0.01),
      LatLng(_currentLocation!.latitude! - 0.01,
          _currentLocation!.longitude! - 0.01),
    ];

    setState(() {
      // Marqueur pour la position actuelle
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      // Marqueurs pour les points de livraison
      for (var i = 0; i < deliveryPoints.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('delivery_$i'),
            position: deliveryPoints[i],
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );

        // Trajet entre la position actuelle et le point de livraison
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route_$i'),
            points: [
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              deliveryPoints[i],
            ],
            color: CupertinoColors.systemBlue,
            width: 3,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: themeProvider.isDarkMode
            ? CupertinoColors.black
            : const Color(0xFFF2F2F7),
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.cube_box_fill,
                    color: CupertinoColors.white,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '12 missions disponibles',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Carte Google Maps
            _currentLocation == null
                ? const Center(child: CupertinoActivityIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      zoom: 13,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers: _markers,
                    polylines: _polylines,
                  ),
            // Overlay pour le mode sombre
            if (themeProvider.isDarkMode)
              Container(
                color: CupertinoColors.black.withOpacity(0.3),
              ),
            // Liste des missions
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.darkBackgroundGray
                        : const Color(0xFFF2F2F7),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Missions disponibles',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMissionCard(
                        themeProvider: themeProvider,
                        title: 'Livraison urgente',
                        address: '123 Rue de la Paix, Paris',
                        distance: '2.5 km',
                        price: '15 €',
                        time: '30 min',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => MissionDetailsScreen(
                                title: 'Livraison urgente',
                                address: '123 Rue de la Paix, Paris',
                                distance: '2.5 km',
                                price: '15 €',
                                time: '30 min',
                                position: LatLng(
                                  _currentLocation!.latitude! + 0.01,
                                  _currentLocation!.longitude! + 0.01,
                                ),
                                pickupPosition: LatLng(
                                  _currentLocation!.latitude! - 0.01,
                                  _currentLocation!.longitude! - 0.01,
                                ),
                                pickupAddress: '78 Rue de Rivoli, 75004 Paris',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMissionCard(
                        themeProvider: themeProvider,
                        title: 'Pièces mécaniques',
                        address: '45 Avenue des Champs-Élysées, Paris',
                        distance: '4.2 km',
                        price: '22 €',
                        time: '45 min',
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => MissionDetailsScreen(
                                title: 'Livraison de pièces auto',
                                address:
                                    '123 Avenue des Champs-Élysées, 75008 Paris',
                                distance: '12 km',
                                price: '45€',
                                time: '25 min',
                                position:
                                    const LatLng(48.8566, 2.3522), // Paris
                                pickupPosition: const LatLng(
                                    48.8584, 2.2945), // Garage Auto Paris
                                pickupAddress:
                                    '45 Rue de la Pompe, 75016 Paris',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard({
    required ThemeProvider themeProvider,
    required String title,
    required String address,
    required String distance,
    required String price,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    price,
                    style: TextStyle(
                      color: CupertinoColors.systemGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.location_solid,
                  size: 16,
                  color: themeProvider.isDarkMode
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_right_circle,
                      size: 16,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      distance,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.time,
                      size: 16,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
