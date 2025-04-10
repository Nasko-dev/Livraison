import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mon profil'),
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/1.jpg'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'John Doe',
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
                    'john.doe@example.com',
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
                    context: context,
                    themeProvider: themeProvider,
                    icon: CupertinoIcons.person,
                    title: 'Informations personnelles',
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              const InformationsPersonnellesScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context: context,
                    themeProvider: themeProvider,
                    icon: CupertinoIcons.car,
                    title: 'Mon véhicule',
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const VehiculeScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context: context,
                    themeProvider: themeProvider,
                    icon: CupertinoIcons.creditcard,
                    title: 'Moyens de paiement',
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const MoyensPaiementScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    context: context,
                    themeProvider: themeProvider,
                    icon: CupertinoIcons.settings,
                    title: 'Paramètres',
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ParametresScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => CupertinoTabScaffold(
                      tabBar: CupertinoTabBar(
                        items: const [
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.home),
                            label: 'Accueil',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.map),
                            label: 'Carte',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.plus_circle),
                            label: 'Nouvelle',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.list_bullet),
                            label: 'Mes livraisons',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.person),
                            label: 'Profil',
                          ),
                        ],
                      ),
                      tabBuilder: (context, index) {
                        return const WelcomeScreen();
                      },
                    ),
                  ),
                  (route) => false,
                );
              },
              child: Container(
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
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_right_square,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemRed,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Déconnexion',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode
                            ? CupertinoColors.systemRed
                            : CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: themeProvider.isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
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
              color: themeProvider.isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}
