import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class VehiculeScreen extends StatefulWidget {
  const VehiculeScreen({super.key});

  @override
  State<VehiculeScreen> createState() => _VehiculeScreenState();
}

class _VehiculeScreenState extends State<VehiculeScreen> {
  final TextEditingController _marqueController =
      TextEditingController(text: 'Renault');
  final TextEditingController _modeleController =
      TextEditingController(text: 'Clio');
  final TextEditingController _immatriculationController =
      TextEditingController(text: 'AB-123-CD');
  final TextEditingController _anneeController =
      TextEditingController(text: '2020');
  final TextEditingController _couleurController =
      TextEditingController(text: 'Bleu');
  bool _isEditing = false;

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
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
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
}
