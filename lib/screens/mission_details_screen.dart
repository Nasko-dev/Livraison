import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MissionDetailsScreen extends StatefulWidget {
  final String title;
  final String address;
  final String distance;
  final String price;
  final String time;
  final LatLng position;
  final LatLng pickupPosition; // Position de collecte
  final String pickupAddress; // Adresse de collecte

  const MissionDetailsScreen({
    super.key,
    required this.title,
    required this.address,
    required this.distance,
    required this.price,
    required this.time,
    required this.position,
    required this.pickupPosition,
    required this.pickupAddress,
  });

  @override
  State<MissionDetailsScreen> createState() => _MissionDetailsScreenState();
}

class _MissionDetailsScreenState extends State<MissionDetailsScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    setState(() {
      // Marqueur pour le point de départ
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: widget.pickupPosition,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      // Marqueur pour le point d'arrivée
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: widget.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Trajet entre les deux points
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [widget.pickupPosition, widget.position],
          color: CupertinoColors.systemBlue,
          width: 3,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Détails de la mission',
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? CupertinoColors.white
                : CupertinoColors.black,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Carte
            SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.pickupPosition,
                  zoom: 13,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: _markers,
                polylines: _polylines,
              ),
            ),
            // Overlay pour le mode sombre
            if (themeProvider.isDarkMode)
              Positioned.fill(
                child: Container(
                  color: CupertinoColors.black.withOpacity(0.3),
                ),
              ),
            // Détails de la mission
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    themeProvider: themeProvider,
                    title: 'Point de départ',
                    address: widget.pickupAddress,
                    icon: CupertinoIcons.location_solid,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    themeProvider: themeProvider,
                    title: 'Point d\'arrivée',
                    address: widget.address,
                    icon: CupertinoIcons.flag_fill,
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          themeProvider: themeProvider,
                          icon: CupertinoIcons.arrow_right_circle,
                          label: 'Distance',
                          value: widget.distance,
                        ),
                        _buildInfoItem(
                          themeProvider: themeProvider,
                          icon: CupertinoIcons.time,
                          label: 'Temps',
                          value: widget.time,
                        ),
                        _buildInfoItem(
                          themeProvider: themeProvider,
                          icon: CupertinoIcons.money_dollar,
                          label: 'Prix',
                          value: widget.price,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    onPressed: () {
                      // TODO: Implémenter l'acceptation de la mission
                    },
                    child: const Text('Accepter la mission'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeProvider themeProvider,
    required String title,
    required String address,
    required IconData icon,
  }) {
    return Container(
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
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                icon,
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
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required ThemeProvider themeProvider,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: themeProvider.isDarkMode
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: themeProvider.isDarkMode
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode
                ? CupertinoColors.white
                : CupertinoColors.black,
          ),
        ),
      ],
    );
  }
}
