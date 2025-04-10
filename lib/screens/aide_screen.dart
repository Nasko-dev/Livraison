import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AideScreen extends StatefulWidget {
  const AideScreen({super.key});

  @override
  State<AideScreen> createState() => _AideScreenState();
}

class _AideScreenState extends State<AideScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Aide'),
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
                    'Questions fréquentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFaqItem(
                    context: context,
                    themeProvider: themeProvider,
                    question: 'Comment devenir livreur ?',
                    answer:
                        'Pour devenir livreur, vous devez avoir un véhicule en bon état et un permis de conduire valide. Rendez-vous dans la section "Profil" pour compléter votre inscription.',
                  ),
                  const Divider(),
                  _buildFaqItem(
                    context: context,
                    themeProvider: themeProvider,
                    question: 'Comment sont calculés les frais de livraison ?',
                    answer:
                        'Les frais de livraison sont calculés en fonction de la distance, du type de véhicule et de la demande du marché.',
                  ),
                  const Divider(),
                  _buildFaqItem(
                    context: context,
                    themeProvider: themeProvider,
                    question: 'Comment retirer mes gains ?',
                    answer:
                        'Vous pouvez retirer vos gains à tout moment depuis la section "Ma cagnotte". Les retraits sont traités sous 24 à 48 heures.',
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
                    'Contact',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    context: context,
                    themeProvider: themeProvider,
                    icon: CupertinoIcons.phone,
                    title: 'Support téléphonique',
                    subtitle: '01 23 45 67 89',
                    onTap: () {
                      // TODO: Implémenter l'appel téléphonique
                    },
                  ),
                  const Divider(),
                  _buildContactItem(
                    context: context,
                    themeProvider: themeProvider,
                    icon: CupertinoIcons.mail,
                    title: 'Email',
                    subtitle: 'support@livraison.com',
                    onTap: () {
                      // TODO: Implémenter l'envoi d'email
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required String question,
    required String answer,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode
                  ? CupertinoColors.white
                  : CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
          ],
        ),
      ),
    );
  }
}
