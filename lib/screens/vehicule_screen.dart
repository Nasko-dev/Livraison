import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';

class VehiculeScreen extends StatefulWidget {
  const VehiculeScreen({super.key});

  @override
  State<VehiculeScreen> createState() => _VehiculeScreenState();
}

class _VehiculeScreenState extends State<VehiculeScreen> {
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _immatriculationController =
      TextEditingController();
  final TextEditingController _anneeController = TextEditingController();
  final TextEditingController _couleurController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  String _selectedType = 'voiture';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicleData();
    });
  }

  void _loadVehicleData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final User? user = authProvider.user;

    if (user != null) {
      developer.log('Chargement des données véhicule pour: ${user.name}',
          name: 'VehiculeScreen');

      // Convertir le type de véhicule de l'utilisateur
      try {
        _selectedType = user.vehicleType == 'car'
            ? 'voiture'
            : user.vehicleType == 'bike'
                ? 'velo'
                : user.vehicleType == 'truck'
                    ? 'camion'
                    : user.vehicleType;
      } catch (e) {
        _selectedType = 'voiture';
        developer.log(
            'Erreur lors de la conversion du type: ${user.vehicleType}',
            name: 'VehiculeScreen');
      }

      // Essayer d'abord de charger depuis le modèle utilisateur
      bool vehicleLoaded = false;

      // Si nous avons un objet chauffeur dans les données utilisateur
      if (user.toJson().containsKey('chauffeur')) {
        final chauffeurData = user.toJson()['chauffeur'];
        if (chauffeurData != null && chauffeurData['vehicle'] != null) {
          final vehicleData = chauffeurData['vehicle'];
          setState(() {
            _marqueController.text =
                vehicleData['make'] ?? vehicleData['brand'] ?? '';
            _modeleController.text = vehicleData['model'] ?? '';
            _immatriculationController.text = vehicleData['licensePlate'] ?? '';
            _anneeController.text = (vehicleData['year'] ?? '').toString();
            _couleurController.text = vehicleData['color'] ?? '';

            if (vehicleData['vehicleType'] != null) {
              _selectedType = vehicleData['vehicleType'];
            } else if (vehicleData['type'] != null) {
              _selectedType = vehicleData['type'];
            }
          });
          vehicleLoaded = true;
        }
      }

      // Si le véhicule n'a pas été chargé depuis le modèle utilisateur, essayer via l'API Strapi
      if (!vehicleLoaded) {
        try {
          final jwt = await const FlutterSecureStorage().read(key: 'jwt');
          if (jwt != null) {
            final dio = Dio();
            dio.options.baseUrl = 'http://192.168.1.102:1337';

            // Récupérer l'ID utilisateur
            final userResponse = await dio.get(
              '/api/users/me',
              options: Options(
                headers: {'Authorization': 'Bearer $jwt'},
                validateStatus: (status) => true,
              ),
            );

            if (userResponse.statusCode == 200) {
              // Corriger ici: l'ID est directement dans la réponse, pas dans data
              final userId =
                  userResponse.data['id'] ?? userResponse.data['data']?['id'];
              developer.log('ID utilisateur trouvé: $userId',
                  name: 'VehiculeScreen');

              if (userId != null) {
                // Utiliser le nouvel endpoint user pour récupérer le véhicule
                final vehicleResponse = await dio.get(
                  '/api/vehicles/user/$userId',
                  options: Options(
                    headers: {'Authorization': 'Bearer $jwt'},
                    validateStatus: (status) => true,
                  ),
                );

                if (vehicleResponse.statusCode == 200 &&
                    vehicleResponse.data != null) {
                  final vehicleData = vehicleResponse.data['attributes'] ??
                      vehicleResponse.data;

                  setState(() {
                    _marqueController.text = vehicleData['make'] ?? '';
                    _modeleController.text = vehicleData['model'] ?? '';
                    _immatriculationController.text =
                        vehicleData['licensePlate'] ?? '';
                    _anneeController.text =
                        (vehicleData['year'] ?? '').toString();
                    _couleurController.text = vehicleData['color'] ?? '';
                    _selectedType = vehicleData['vehicleType'] ?? 'voiture';
                  });
                  vehicleLoaded = true;
                }
              } else {
                developer.log('Impossible de récupérer l\'ID utilisateur',
                    name: 'VehiculeScreen');
              }
            }
          }
        } catch (e) {
          developer.log('Erreur lors du chargement via API: $e',
              name: 'VehiculeScreen');
        }
      }

      // Si le véhicule n'a pas été chargé, utiliser des valeurs par défaut
      if (!vehicleLoaded) {
        setState(() {
          _marqueController.text = '';
          _modeleController.text = '';
          _immatriculationController.text = '';
          _anneeController.text = DateTime.now().year.toString();
          _couleurController.text = '';
        });
      }
    }
  }

  Future<void> _saveVehicleData() async {
    if (!_isEditing) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Utiliser directement l'API publique de Strapi
      final jwt = await const FlutterSecureStorage().read(key: 'jwt');
      if (jwt == null) {
        throw Exception("Vous n'êtes pas connecté");
      }

      final dio = Dio();
      dio.options.baseUrl = 'http://192.168.1.102:1337';

      // Activer les logs détaillés de Dio
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        request: true,
        requestHeader: true,
        responseHeader: true,
      ));

      // Récupérer l'ID utilisateur
      final userResponse = await dio.get(
        '/api/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
          validateStatus: (status) => true,
        ),
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Impossible de récupérer les informations utilisateur');
      }

      // Corriger l'extraction de l'ID utilisateur
      final userId =
          userResponse.data['id'] ?? userResponse.data['data']?['id'];
      if (userId == null) {
        throw Exception('ID utilisateur non trouvé dans la réponse');
      }

      developer.log('ID utilisateur: $userId', name: 'VehiculeScreen');

      // Préparer les données du véhicule
      Map<String, dynamic> vehicleData = {
        'make': _marqueController.text,
        'model': _modeleController.text,
        'licensePlate': _immatriculationController.text,
        'year': int.tryParse(_anneeController.text) ?? DateTime.now().year,
        'color': _couleurController.text,
        'vehicleType': _selectedType,
      };

      // Vérifier que tous les champs requis sont remplis
      if (_marqueController.text.isEmpty || _modeleController.text.isEmpty) {
        throw Exception(
            "Veuillez remplir au moins la marque et le modèle du véhicule");
      }

      developer.log('🚗 Données véhicule à envoyer: $vehicleData',
          name: 'VehiculeScreen');

      // Utiliser directement l'endpoint createOrUpdateByUserId qui gère les relations automatiquement
      final response = await dio.post(
        '/api/vehicles/user/$userId',
        data: {'data': vehicleData},
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
          validateStatus: (status) => true,
        ),
      );

      developer.log('Statut opération véhicule: ${response.statusCode}',
          name: 'VehiculeScreen');
      developer.log('Réponse: ${response.data}', name: 'VehiculeScreen');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Erreur lors de l\'opération sur le véhicule: ${response.data}');
      }

      developer.log('✅ Mise à jour réussie!', name: 'VehiculeScreen');

      // Actualiser les données utilisateur dans le provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Succès'),
            content: const Text(
                'Les informations de votre véhicule ont été mises à jour.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      developer.log('❌ ERREUR CRITIQUE: $e', name: 'VehiculeScreen');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Erreur'),
            content: Text('Une erreur est survenue: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _immatriculationController.dispose();
    _anneeController.dispose();
    _couleurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Mon véhicule'),
        trailing: _isSaving
            ? Container(
                padding: const EdgeInsets.all(8),
                child: const CupertinoActivityIndicator(),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (_isEditing) {
                    _saveVehicleData();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                child: Text(_isEditing ? 'Enregistrer' : 'Modifier'),
              ),
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
                children: [
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Marque',
                    controller: _marqueController,
                    isEditing: _isEditing,
                    icon: CupertinoIcons.car_detailed,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Modèle',
                    controller: _modeleController,
                    isEditing: _isEditing,
                    icon: CupertinoIcons.car,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Immatriculation',
                    controller: _immatriculationController,
                    isEditing: _isEditing,
                    icon: CupertinoIcons.rectangle_badge_checkmark,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Année',
                    controller: _anneeController,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.number,
                    icon: CupertinoIcons.calendar,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Couleur',
                    controller: _couleurController,
                    isEditing: _isEditing,
                    icon: CupertinoIcons.paintbrush,
                  ),
                  const Divider(),
                  _buildTypeSelector(
                    themeProvider: themeProvider,
                    isEditing: _isEditing,
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
                    'Documents du véhicule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentItem(
                    themeProvider: themeProvider,
                    title: 'Carte grise',
                    status: 'Validé',
                  ),
                  const Divider(),
                  _buildDocumentItem(
                    themeProvider: themeProvider,
                    title: 'Assurance',
                    status: 'En attente',
                  ),
                  const Divider(),
                  _buildDocumentItem(
                    themeProvider: themeProvider,
                    title: 'Contrôle technique',
                    status: 'À fournir',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required ThemeProvider themeProvider,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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
                  label,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? CupertinoTextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        maxLines: maxLines,
                        decoration: null,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      )
                    : Text(
                        controller.text,
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required ThemeProvider themeProvider,
    required String title,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case 'Validé':
        statusColor = CupertinoColors.systemGreen;
        break;
      case 'En attente':
        statusColor = CupertinoColors.systemOrange;
        break;
      default:
        statusColor = CupertinoColors.systemRed;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? CupertinoColors.white
                    : CupertinoColors.black,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // TODO: Implémenter l'action de téléchargement/modification
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.cloud_upload,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector({
    required ThemeProvider themeProvider,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.car_fill,
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
                  'Type de véhicule',
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 4),
                isEditing
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _showTypeSelector(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: CupertinoColors.systemGrey3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  _getVehicleTypeLabel(_selectedType),
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                              ),
                              const Icon(CupertinoIcons.chevron_down, size: 16),
                            ],
                          ),
                        ),
                      )
                    : Text(
                        _getVehicleTypeLabel(_selectedType),
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Liste des types de véhicules disponibles
    final List<String> vehicleTypes = ['voiture', 'scooter', 'velo', 'camion'];

    // Trouver l'index du type sélectionné
    int initialIndex = vehicleTypes.indexOf(_selectedType);
    if (initialIndex < 0) initialIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: themeProvider.isDarkMode
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.systemBackground,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Annuler'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: const Text('Valider'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  onSelectedItemChanged: (int selectedItem) {
                    setState(() {
                      _selectedType = vehicleTypes[selectedItem];
                    });
                  },
                  children: vehicleTypes
                      .map(
                        (type) => Center(
                          child: Text(
                            _getVehicleTypeLabel(type),
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon() {
    switch (_selectedType) {
      case 'voiture':
        return CupertinoIcons.car_detailed;
      case 'velo':
        return CupertinoIcons.sportscourt; // Pas d'icône de vélo, alternative
      case 'scooter':
        return CupertinoIcons.scribble; // Pas d'icône de scooter, alternative
      case 'camion':
        return CupertinoIcons.bus; // Pas d'icône de camion, alternative
      default:
        return CupertinoIcons.car_detailed;
    }
  }

  String _getVehicleTypeLabel(String type) {
    switch (type) {
      case 'voiture':
        return 'Voiture';
      case 'velo':
        return 'Vélo';
      case 'scooter':
        return 'Scooter';
      case 'camion':
        return 'Camion';
      default:
        return 'Voiture';
    }
  }
}
