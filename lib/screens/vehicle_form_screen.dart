import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({Key? key, this.vehicle}) : super(key: key);

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  String _selectedVehicleType = 'voiture';
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    developer.log('🚗 Initialisation de l\'écran de véhicule',
        name: 'VehicleForm');
    _loadVehicleData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    developer.log('🔄 Changement de dépendances détecté', name: 'VehicleForm');
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Si un véhicule a été passé en paramètre, l'utiliser
      if (widget.vehicle != null) {
        developer.log('🔄 Utilisation du véhicule passé en paramètre',
            name: 'VehicleForm');
        developer.log('📊 Données du véhicule: ${widget.vehicle!.toJson()}',
            name: 'VehicleForm');
        _preloadVehicleData(widget.vehicle!);
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      // Sinon, charger depuis l'API
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);

      if (authProvider.user != null) {
        // Utilisateur connecté, charger son véhicule
        final userId = authProvider.user!.id;
        developer.log(
            '🔍 Chargement du véhicule pour l\'utilisateur ID: $userId',
            name: 'VehicleForm');
        developer.log(
            '👤 Informations utilisateur: ${authProvider.user!.toJson()}',
            name: 'VehicleForm');

        await vehicleProvider.loadVehicleForUser(userId);

        if (vehicleProvider.vehicle != null) {
          // Véhicule trouvé, remplir les champs
          developer.log(
              '✅ Véhicule trouvé: ${vehicleProvider.vehicle!.toJson()}',
              name: 'VehicleForm');
          developer.log('📝 Détails du véhicule:', name: 'VehicleForm');
          developer.log('   - Marque: ${vehicleProvider.vehicle!.make}',
              name: 'VehicleForm');
          developer.log('   - Modèle: ${vehicleProvider.vehicle!.model}',
              name: 'VehicleForm');
          developer.log('   - Année: ${vehicleProvider.vehicle!.year}',
              name: 'VehicleForm');
          developer.log(
              '   - Immatriculation: ${vehicleProvider.vehicle!.licensePlate}',
              name: 'VehicleForm');
          developer.log('   - Couleur: ${vehicleProvider.vehicle!.color}',
              name: 'VehicleForm');
          developer.log('   - Type: ${vehicleProvider.vehicle!.vehicleType}',
              name: 'VehicleForm');
          _preloadVehicleData(vehicleProvider.vehicle!);
        } else if (vehicleProvider.error != null) {
          // Erreur lors du chargement
          developer.log(
              '❌ Erreur lors du chargement du véhicule: ${vehicleProvider.error}',
              name: 'VehicleForm');
          setState(() {
            _errorMessage = vehicleProvider.error;
          });
        } else {
          // Aucun véhicule trouvé
          developer.log('ℹ️ Aucun véhicule trouvé pour l\'utilisateur',
              name: 'VehicleForm');
          developer.log('📝 Initialisation avec valeurs par défaut',
              name: 'VehicleForm');

          // Initialiser avec des valeurs par défaut
          setState(() {
            _makeController.text = '';
            _modelController.text = '';
            _yearController.text = DateTime.now().year.toString();
            _licensePlateController.text = '';
            _colorController.text = '';
            _selectedVehicleType = authProvider.user?.vehicleType ?? 'voiture';
          });
        }
      } else {
        // Aucun utilisateur connecté
        developer.log('⚠️ Aucun utilisateur connecté', name: 'VehicleForm');
        setState(() {
          _errorMessage =
              'Vous devez être connecté pour accéder à cette fonctionnalité';
        });
      }
    } catch (e) {
      developer.log('❌ Erreur lors du chargement des données: $e',
          name: 'VehicleForm');
      setState(() {
        _errorMessage = 'Une erreur est survenue: $e';
      });
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void _preloadVehicleData(Vehicle vehicle) {
    developer.log('🔄 Pré-chargement des données du véhicule ID: ${vehicle.id}',
        name: 'VehicleForm');
    developer.log('📊 Données à charger:', name: 'VehicleForm');
    developer.log('   - Marque: ${vehicle.make}', name: 'VehicleForm');
    developer.log('   - Modèle: ${vehicle.model}', name: 'VehicleForm');
    developer.log('   - Année: ${vehicle.year}', name: 'VehicleForm');
    developer.log('   - Immatriculation: ${vehicle.licensePlate}',
        name: 'VehicleForm');
    developer.log('   - Couleur: ${vehicle.color}', name: 'VehicleForm');
    developer.log('   - Type: ${vehicle.vehicleType}', name: 'VehicleForm');

    setState(() {
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _licensePlateController.text = vehicle.licensePlate;
      _colorController.text = vehicle.color;
      _selectedVehicleType = vehicle.vehicleType;
    });

    developer.log('📝 Champs remplis avec succès', name: 'VehicleForm');
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Vérifier que les données utilisateur sont disponibles
      if (authProvider.user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Utilisateur non connecté';
        });
        return;
      }

      // Utiliser l'ID de l'utilisateur et pas celui du chauffeur
      final userId = authProvider.user!.id;

      // Logs pour le debugging
      developer.log('🚗 Sauvegarde du véhicule:', name: 'VehicleForm');
      developer.log('👤 ID Utilisateur: $userId', name: 'VehicleForm');
      developer.log('🧑‍✈️ Chauffeur: ${authProvider.user?.chauffeur?.id}',
          name: 'VehicleForm');
      developer.log(
          '🔑 Utilisateur authentifié: ${authProvider.isAuthenticated}',
          name: 'VehicleForm');

      // Créer l'objet véhicule
      final vehicle = Vehicle(
        id: vehicleProvider.vehicle?.id, // Utiliser l'ID du véhicule existant
        make: _makeController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        licensePlate: _licensePlateController.text,
        color: _colorController.text,
        vehicleType: _selectedVehicleType,
        chauffeurId: authProvider.user?.chauffeur?.id,
      );

      // Utiliser la méthode qui gère à la fois la création et la mise à jour
      try {
        bool success =
            await vehicleProvider.createOrUpdateVehicleForUser(userId, vehicle);

        setState(() {
          _isLoading = false;
        });

        if (success) {
          if (mounted) {
            _showSuccess();
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage =
                  vehicleProvider.error ?? 'Une erreur est survenue';
            });
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erreur: $e';
        });
        developer.log('❌ Erreur lors de la sauvegarde: $e',
            name: 'VehicleForm');
      }
    }
  }

  Future<void> _showSuccess() async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Succès'),
        content: Text(
            Provider.of<VehicleProvider>(context, listen: false).vehicle == null
                ? 'Votre véhicule a été ajouté avec succès'
                : 'Votre véhicule a été mis à jour avec succès'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Retourner à l'écran précédent
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(Provider.of<VehicleProvider>(context).vehicle == null
            ? 'Ajouter un véhicule'
            : 'Modifier le véhicule'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: _isInitializing
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Message d'erreur
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.destructiveRed
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CupertinoColors.destructiveRed
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: CupertinoColors.destructiveRed,
                              ),
                            ),
                          ),

                        // Image du véhicule avec type
                        Container(
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              _getVehicleIcon(),
                              size: 60,
                              color: CupertinoColors.systemBlue,
                            ),
                          ),
                        ),

                        // Type de véhicule
                        const Text(
                          'Type de véhicule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                            ),
                          ),
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: _selectedVehicleType,
                            children: const {
                              'voiture': Text('Voiture'),
                              'scooter': Text('Scooter'),
                              'velo': Text('Vélo'),
                              'camion': Text('Camion'),
                            },
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedVehicleType = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Marque
                        _buildInputField(
                          controller: _makeController,
                          label: 'Marque',
                          placeholder: 'Ex: Renault, Peugeot, Toyota...',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La marque est requise';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Modèle
                        _buildInputField(
                          controller: _modelController,
                          label: 'Modèle',
                          placeholder: 'Ex: Clio, 208, Yaris...',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Le modèle est requis';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Année
                        _buildInputField(
                          controller: _yearController,
                          label: 'Année',
                          placeholder: 'Ex: 2018',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'L\'année est requise';
                            }
                            try {
                              final year = int.parse(value);
                              if (year < 1900 ||
                                  year > DateTime.now().year + 1) {
                                return 'Année invalide';
                              }
                            } catch (e) {
                              return 'Veuillez entrer un nombre valide';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Immatriculation
                        _buildInputField(
                          controller: _licensePlateController,
                          label: 'Immatriculation',
                          placeholder: 'Ex: AB-123-CD',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'L\'immatriculation est requise';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Couleur
                        _buildInputField(
                          controller: _colorController,
                          label: 'Couleur',
                          placeholder: 'Ex: Rouge, Noir, Blanc...',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La couleur est requise';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Bouton de sauvegarde
                        SizedBox(
                          height: 50,
                          child: _isLoading
                              ? const Center(
                                  child: CupertinoActivityIndicator(),
                                )
                              : CupertinoButton.filled(
                                  onPressed: _saveVehicle,
                                  child: Text(
                                    Provider.of<VehicleProvider>(context)
                                                .vehicle ==
                                            null
                                        ? 'Ajouter mon véhicule'
                                        : 'Mettre à jour mon véhicule',
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextFormFieldRow(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          validator: validator,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CupertinoColors.systemGrey4,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ],
    );
  }

  IconData _getVehicleIcon() {
    switch (_selectedVehicleType) {
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
}
