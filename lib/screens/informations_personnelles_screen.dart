import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class InformationsPersonnellesScreen extends StatefulWidget {
  const InformationsPersonnellesScreen({super.key});

  @override
  State<InformationsPersonnellesScreen> createState() =>
      _InformationsPersonnellesScreenState();
}

class _InformationsPersonnellesScreenState
    extends State<InformationsPersonnellesScreen> {
  final TextEditingController _nomController =
      TextEditingController(text: 'John');
  final TextEditingController _prenomController =
      TextEditingController(text: 'Doe');
  final TextEditingController _emailController =
      TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _telephoneController =
      TextEditingController(text: '06 12 34 56 78');
  final TextEditingController _adresseController =
      TextEditingController(text: '123 rue de Paris, 75001 Paris');
  final TextEditingController _villeController =
      TextEditingController(text: 'Paris');
  final TextEditingController _codePostalController =
      TextEditingController(text: '75000');
  bool _isEditing = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
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
        middle: const Text('Informations personnelles'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations de base',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Nom',
                    controller: _nomController,
                    isEditing: _isEditing,
                    icon: CupertinoIcons.person,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Prénom',
                    controller: _prenomController,
                    isEditing: _isEditing,
                    icon: CupertinoIcons.person_2,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Email',
                    controller: _emailController,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    icon: CupertinoIcons.mail,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Téléphone',
                    controller: _telephoneController,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.phone,
                    icon: CupertinoIcons.phone,
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
                    'Adresse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Adresse',
                    controller: _adresseController,
                    isEditing: _isEditing,
                    maxLines: 2,
                    icon: CupertinoIcons.location,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Ville',
                    controller: _villeController,
                    isEditing: _isEditing,
                    icon: CupertinoIcons.building_2_fill,
                  ),
                  const Divider(),
                  _buildInfoField(
                    themeProvider: themeProvider,
                    label: 'Code postal',
                    controller: _codePostalController,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.number,
                    icon: CupertinoIcons.number,
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
                  const Text(
                    'Documents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentItem(
                    themeProvider: themeProvider,
                    title: 'Permis de conduire',
                    status: 'Validé',
                    icon: CupertinoIcons.doc_checkmark,
                  ),
                  const Divider(),
                  _buildDocumentItem(
                    themeProvider: themeProvider,
                    title: 'Carte d\'identité',
                    status: 'En attente',
                    icon: CupertinoIcons.doc_plaintext,
                  ),
                  const Divider(),
                  _buildDocumentItem(
                    themeProvider: themeProvider,
                    title: 'Justificatif de domicile',
                    status: 'À fournir',
                    icon: CupertinoIcons.doc_text,
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
    required IconData icon,
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
                  title,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                  ),
                ),
              ],
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
