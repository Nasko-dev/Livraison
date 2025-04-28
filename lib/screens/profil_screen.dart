import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../widgets/bottom_nav_bar.dart';
import 'informations_personnelles_screen.dart';
import 'vehicule_screen.dart';
import 'moyens_paiement_screen.dart';
import 'parametres_screen.dart';
import 'welcome_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  int _currentIndex = 4; // Index pour l'onglet Profil
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Actualiser les données utilisateur au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  Future<void> _refreshUserData() async {
    try {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
      developer.log('Profil utilisateur actualisé', name: 'ProfilScreen');
    } catch (e) {
      developer.log('Erreur lors de l\'actualisation: $e',
          name: 'ProfilScreen');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isLoading) {
      developer.log('⚠️ Une opération est déjà en cours', name: 'ProfilScreen');
      return;
    }

    try {
      setState(() => _isLoading = true);
      developer.log('🔄 Début du processus de sélection et upload d\'avatar',
          name: 'ProfilScreen');

      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked == null) {
        developer.log('ℹ️ Aucune image sélectionnée', name: 'ProfilScreen');
        return;
      }

      developer.log('📁 Image sélectionnée: ${picked.path}',
          name: 'ProfilScreen');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      developer.log('🔑 Tentative d\'upload de l\'avatar...',
          name: 'ProfilScreen');

      try {
        final success = await authProvider.uploadAvatar(File(picked.path));

        if (success) {
          developer.log('✅ Avatar mis à jour avec succès',
              name: 'ProfilScreen');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar mis à jour avec succès')),
            );
          }
        } else {
          throw Exception(
              'Échec de la mise à jour de l\'avatar - Réponse négative du provider');
        }
      } catch (uploadError) {
        developer.log('❌ Erreur lors de l\'upload: $uploadError',
            name: 'ProfilScreen');
        throw Exception('Erreur lors de l\'upload: $uploadError');
      }
    } catch (e) {
      developer.log('❌ Erreur globale lors de l\'upload de l\'avatar: $e',
          name: 'ProfilScreen');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Erreur'),
            content: Text(
              'Une erreur est survenue lors de la mise à jour de l\'avatar:\n\n$e',
              style: const TextStyle(fontSize: 14),
            ),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Déconnexion'),
            onPressed: () async {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(Widget screen) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => screen),
    );
    if (mounted) _refreshUserData();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Mon profil'),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.refresh),
                onPressed: _refreshUserData,
              ),
      ),
      child: SafeArea(
        bottom: false,
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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: CupertinoColors.systemGrey5,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null
                              ? Icon(
                                  CupertinoIcons.person,
                                  size: 40,
                                  color: CupertinoColors.systemGrey,
                                )
                              : null,
                        ),
                      ),
                      if (_isLoading)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: CupertinoActivityIndicator(radius: 10),
                        )
                      else
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  CupertinoColors.systemGrey.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.camera,
                              size: 16,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user != null
                        ? '${user.name} ${user.surname}'
                        : 'Non connecté',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Pas d\'email',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? 'Pas de téléphone',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(user.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusLabel(user.status),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(user.status),
                        ),
                      ),
                    ),
                  ],
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
                children: [
                  _buildMenuItem(
                    icon: CupertinoIcons.person,
                    title: 'Informations personnelles',
                    onTap: () => _navigateToScreen(
                        const InformationsPersonnellesScreen()),
                  ),
                  // const Divider(),
                  // _buildMenuItem(
                  //   icon: CupertinoIcons.car_detailed,
                  //   title: 'Mon véhicule',
                  //   onTap: () => _navigateToScreen(const VehiculeScreen()),
                  // ),
                  const Divider(),
                  _buildMenuItem(
                    icon: CupertinoIcons.creditcard,
                    title: 'Moyens de paiement',
                    onTap: () =>
                        _navigateToScreen(const MoyensPaiementScreen()),
                  ),
                  const Divider(),
                  _buildMenuItem(
                    icon: CupertinoIcons.settings,
                    title: 'Paramètres',
                    onTap: () => _navigateToScreen(const ParametresScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _handleLogout,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: CupertinoColors.destructiveRed.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                width: 200,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 60),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.square_arrow_left,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (authProvider.isLoading)
              Container(
                margin: const EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      // Si vous avez un BottomNavBar, vous pouvez l'activer ici :
      // bottomNavigationBar: BottomNavBar(currentIndex: _currentIndex),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return CupertinoColors.activeGreen;
      case 'pending':
        return CupertinoColors.systemOrange;
      case 'suspended':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Actif';
      case 'pending':
        return 'En attente';
      case 'suspended':
        return 'Suspendu';
      default:
        return 'Statut inconnu';
    }
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode
                    ? CupertinoColors.white
                    : CupertinoColors.black,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}
