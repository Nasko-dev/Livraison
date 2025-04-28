import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? CupertinoColors.black.withOpacity(0.2)
                : CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: themeProvider.isDarkMode
                ? CupertinoColors.darkBackgroundGray.withOpacity(0.8)
                : CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      margin: EdgeInsets.only(top: 10),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: CupertinoTabBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          activeColor: CupertinoColors.systemBlue,
          inactiveColor: themeProvider.isDarkMode
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey,
          iconSize: 24,
          height: 60,
          border: Border.all(color: Colors.transparent),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.car_detailed),
              label: 'Livraisons',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.money_dollar_circle),
              label: 'Cagnotte',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.question_circle),
              label: 'Aide',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_circle),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
