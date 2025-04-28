import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'mes_livraisons_screen.dart';
import 'ma_cagnotte_screen.dart';
import 'aide_screen.dart';
import 'profil_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Création des écrans avec des clés de navigateur independantes
  // pour préserver l'état de chaque écran
  final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey('home')),
    const MesLivraisonsScreen(key: PageStorageKey('livraisons')),
    const MaCagnotteScreen(key: PageStorageKey('cagnotte')),
    const AideScreen(key: PageStorageKey('aide')),
    const ProfilScreen(key: PageStorageKey('profil')),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      child: Column(
        children: [
          // Zone principale de contenu qui occupe tout l'espace disponible
          Expanded(
            child: _screens[_currentIndex],
          ),
          // Barre de navigation unique pour toute l'application
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
