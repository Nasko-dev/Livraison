
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../widgets/custom_button.dart';
import '../providers/theme_provider.dart';

class InformationsPersonnellesScreen extends StatefulWidget {
  const InformationsPersonnellesScreen({Key? key}) : super(key: key);

  @override
  State<InformationsPersonnellesScreen> createState() =>
      _InformationsPersonnellesScreenState();
}

class _InformationsPersonnellesScreenState
    extends State<InformationsPersonnellesScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Charger les données après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = authProvider.user;
      final rawData = authProvider.rawUserData;

      dev.log('Chargement des données utilisateur: ${userData?.toJson()}');
      dev.log('Données brutes: $rawData');

      if (userData != null) {
        if (mounted) {
          setState(() {
            _nameController.text = userData.name;
            _surnameController.text = userData.surname;
            _phoneController.text = userData.phone;
            _emailController.text = userData.email;
            _addressController.text = userData.address;
          });
        }
      } else if (rawData != null) {
        // Fallback sur les données brutes
        final data = rawData['data'] ?? rawData;
        if (mounted) {
          setState(() {
            _nameController.text = data['name']?.toString() ?? '';
            _surnameController.text = data['surname']?.toString() ?? '';
            _phoneController.text = data['phone']?.toString() ?? '';
            _emailController.text = data['email']?.toString() ?? '';
            _addressController.text = data['address']?.toString() ?? '';
          });
        }
      } else {
        dev.log('Aucune donnée utilisateur disponible');
        if (mounted) {
          setState(() {
            _errorMessage = 'Impossible de charger les données utilisateur';
          });
        }
      }
    } catch (e) {
      dev.log('Erreur lors du chargement des données utilisateur: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Une erreur est survenue: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (!_isEditing) return;

    if (!mounted) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Vérifier que les champs ne sont pas vides
      if (_nameController.text.trim().isEmpty ||
          _surnameController.text.trim().isEmpty ||
          _phoneController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty) {
        throw 'Veuillez remplir tous les champs obligatoires';
      }

      // Créer un Map avec les données mises à jour
      final Map<String, dynamic> userData = {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
      };

      dev.log('Envoi des données pour mise à jour: $userData');

      // Enregistrer les modifications avec la nouvelle méthode updateProfile
      final success = await authProvider.updateProfile(userData);

      if (success) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Succès'),
              content: const Text(
                  'Informations personnelles mises à jour avec succès'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      } else {
        final errorMsg =
            authProvider.error ?? 'Erreur lors de la mise à jour du profil';
        dev.log('Erreur retournée par l\'API: $errorMsg');
        if (mounted) {
          setState(() {
            _errorMessage = errorMsg;
          });
        }
      }
    } catch (e) {
      dev.log('Erreur lors de la sauvegarde des données: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la sauvegarde: $e';
        });
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Informations personnelles'),
        trailing: _isSaving
            ? Container(
                padding: const EdgeInsets.all(8),
                child: const CupertinoActivityIndicator(),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (_isEditing) {
                    _saveUserData();
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                child: Text(_isEditing ? 'Enregistrer' : 'Modifier'),
              ),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color:
                              CupertinoColors.destructiveRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                CupertinoColors.destructiveRed.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: CupertinoColors.destructiveRed,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildSectionHeader('Coordonnées'),
                          _buildInfoGroup([
                            _buildInfoRow(
                              'Prénom',
                              _nameController,
                              CupertinoIcons.person,
                              enabled: _isEditing,
                            ),
                            _buildInfoRow(
                              'Nom',
                              _surnameController,
                              CupertinoIcons.person_2,
                              enabled: _isEditing,
                            ),
                            _buildInfoRow(
                              'Téléphone',
                              _phoneController,
                              CupertinoIcons.phone,
                              enabled:
                                  false, // Le téléphone ne peut jamais être modifié
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _buildSectionHeader('Adresse Email'),
                          _buildInfoGroup([
                            _buildInfoRow(
                              'Email',
                              _emailController,
                              CupertinoIcons.mail,
                              enabled: _isEditing,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ]),
                          const SizedBox(height: 20),
                          _buildSectionHeader('Adresse'),
                          _buildInfoGroup([
                            _buildInfoRow(
                              'Adresse complète',
                              _addressController,
                              CupertinoIcons.location,
                              enabled: _isEditing,
                              maxLines: 2,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  Widget _buildInfoGroup(List<Widget> children) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? CupertinoColors.darkBackgroundGray
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
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
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2,
                  ),
                ),
                const SizedBox(height: 4),
                CupertinoTextField.borderless(
                  controller: controller,
                  padding: EdgeInsets.zero,
                  enabled: enabled,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  placeholder: 'Non spécifié',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                  placeholderStyle: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
