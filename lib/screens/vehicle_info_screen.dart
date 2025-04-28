import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../providers/auth_provider.dart';
import 'vehicle_form_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({Key? key}) : super(key: key);

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);

    if (authProvider.user?.chauffeur?.id != null) {
      try {
        await vehicleProvider
            .loadVehicleForChauffeur(authProvider.user!.chauffeur!.id!);
      } catch (e) {
        print('Erreur lors du chargement du véhicule: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mon véhicule'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : Consumer<VehicleProvider>(
                builder: (context, vehicleProvider, child) {
                  if (vehicleProvider.isLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final vehicle = vehicleProvider.vehicle;

                  if (vehicle == null) {
                    return _buildNoVehicleView();
                  }

                  return _buildVehicleInfoView(vehicle);
                },
              ),
      ),
    );
  }

  Widget _buildNoVehicleView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.car_detailed,
              size: 80,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Vous n\'avez pas encore ajouté de véhicule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ajoutez les informations de votre véhicule pour commencer à livrer',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: () => _navigateToVehicleForm(null),
              child: const Text('Ajouter mon véhicule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoView(Vehicle vehicle) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête avec icône du véhicule
            Container(
              height: 160,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getVehicleIcon(vehicle.vehicleType),
                      size: 80,
                      color: CupertinoColors.systemBlue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${vehicle.make} ${vehicle.model}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      vehicle.licensePlate,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Informations du véhicule
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemGrey4.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: CupertinoIcons.car_detailed,
                    title: 'Type de véhicule',
                    value: _getVehicleTypeName(vehicle.vehicleType),
                  ),
                  _buildInfoItem(
                    icon: CupertinoIcons.calendar,
                    title: 'Année',
                    value: vehicle.year.toString(),
                  ),
                  _buildInfoItem(
                    icon: CupertinoIcons.paintbrush,
                    title: 'Couleur',
                    value: vehicle.color,
                  ),
                  // Ajouter d'autres informations si nécessaire
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de modification
            CupertinoButton.filled(
              onPressed: () => _navigateToVehicleForm(vehicle),
              child: const Text('Modifier mon véhicule'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: CupertinoColors.systemBlue,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToVehicleForm(Vehicle? vehicle) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => VehicleFormScreen(vehicle: vehicle),
      ),
    );

    if (result == true) {
      // Rafraîchir les données du véhicule
      _loadVehicleData();
    }
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'scooter':
        return CupertinoIcons.scribble;
      case 'velo':
        return CupertinoIcons.sportscourt;
      case 'camion':
        return CupertinoIcons.bus;
      case 'voiture':
      default:
        return CupertinoIcons.car_detailed;
    }
  }

  String _getVehicleTypeName(String vehicleType) {
    switch (vehicleType) {
      case 'scooter':
        return 'Scooter';
      case 'velo':
        return 'Vélo';
      case 'camion':
        return 'Camion';
      case 'voiture':
        return 'Voiture';
      default:
        return vehicleType;
    }
  }
}
