import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/theme_provider.dart';
import 'mission_details_screen.dart';

class MesLivraisonsScreen extends StatefulWidget {
  const MesLivraisonsScreen({super.key});

  @override
  State<MesLivraisonsScreen> createState() => _MesLivraisonsScreenState();
}

class _MesLivraisonsScreenState extends State<MesLivraisonsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mes livraisons'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.systemBackground,
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
                    'En cours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLivraisonItem(
                    context: context,
                    themeProvider: themeProvider,
                    title: 'Livraison de pièces',
                    adresse: '123 Rue de Paris, 75001',
                    statut: 'En cours',
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => MissionDetailsScreen(
                            title: 'Livraison de pièces',
                            address: '123 Rue de Paris, 75001',
                            distance: '5 km',
                            price: '35,00 €',
                            time: '30 min',
                            position: const LatLng(48.8566, 2.3522),
                            pickupPosition: const LatLng(48.8566, 2.3522),
                            pickupAddress: 'Point de départ',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.systemBackground,
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
                    'Historique',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLivraisonItem(
                    context: context,
                    themeProvider: themeProvider,
                    title: 'Livraison express',
                    adresse: '45 Avenue des Champs-Élysées, 75008',
                    statut: 'Terminée',
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => MissionDetailsScreen(
                            title: 'Livraison express',
                            address: '45 Avenue des Champs-Élysées, 75008',
                            distance: '5 km',
                            price: '35,00 €',
                            time: '30 min',
                            position: const LatLng(48.8566, 2.3522),
                            pickupPosition: const LatLng(48.8566, 2.3522),
                            pickupAddress: 'Point de départ',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildLivraisonItem(
                    context: context,
                    themeProvider: themeProvider,
                    title: 'Livraison standard',
                    adresse: '78 Boulevard Haussmann, 75009',
                    statut: 'Terminée',
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => MissionDetailsScreen(
                            title: 'Livraison standard',
                            address: '78 Boulevard Haussmann, 75009',
                            distance: '5 km',
                            price: '35,00 €',
                            time: '30 min',
                            position: const LatLng(48.8566, 2.3522),
                            pickupPosition: const LatLng(48.8566, 2.3522),
                            pickupAddress: 'Point de départ',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivraisonItem({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required String title,
    required String adresse,
    required String statut,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.cube_box,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adresse,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statut == 'En cours'
                    ? CupertinoColors.systemBlue.withOpacity(0.1)
                    : CupertinoColors.systemGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statut,
                style: TextStyle(
                  fontSize: 12,
                  color: statut == 'En cours'
                      ? CupertinoColors.systemBlue
                      : CupertinoColors.systemGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
