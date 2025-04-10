import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/mes_livraisons_screen.dart';
import '../screens/ma_cagnotte_screen.dart';
import '../screens/aide_screen.dart';
import '../screens/profil_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.systemBackground,
        border: Border(
          top: BorderSide(
            color: themeProvider.isDarkMode
                ? CupertinoColors.darkBackgroundGray
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: CupertinoTabBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: themeProvider.isDarkMode
              ? CupertinoColors.darkBackgroundGray
              : CupertinoColors.systemBackground,
          activeColor: CupertinoColors.systemBlue,
          inactiveColor: themeProvider.isDarkMode
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car),
              label: 'Mes livraisons',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.money_dollar),
              label: 'Ma cagnotte',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.question_circle),
              label: 'Aide',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
