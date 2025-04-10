import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MaCagnotteScreen extends StatefulWidget {
  const MaCagnotteScreen({super.key});

  @override
  State<MaCagnotteScreen> createState() => _MaCagnotteScreenState();
}

class _MaCagnotteScreenState extends State<MaCagnotteScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Ma cagnotte'),
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
                  Text(
                    'Solde disponible',
                    style: TextStyle(
                      fontSize: 16,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '185,00 €',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CupertinoButton.filled(
                    onPressed: () {
                      // TODO: Implémenter le retrait
                    },
                    child: const Text('Retirer'),
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
                    'Historique des transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionItem(
                    context: context,
                    themeProvider: themeProvider,
                    date: '15/03/2024',
                    description: 'Retrait de fonds',
                    montant: '-100,00 €',
                    isRetrait: true,
                  ),
                  const Divider(),
                  _buildTransactionItem(
                    context: context,
                    themeProvider: themeProvider,
                    date: '12/03/2024',
                    description: 'Livraison #1231',
                    montant: '+35,00 €',
                    isRetrait: false,
                  ),
                  const Divider(),
                  _buildTransactionItem(
                    context: context,
                    themeProvider: themeProvider,
                    date: '10/03/2024',
                    description: 'Livraison #1228',
                    montant: '+50,00 €',
                    isRetrait: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required String date,
    required String description,
    required String montant,
    required bool isRetrait,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isRetrait
                  ? CupertinoColors.systemRed.withOpacity(0.1)
                  : CupertinoColors.systemGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isRetrait ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
              color: isRetrait
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            montant,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isRetrait
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGreen,
            ),
          ),
        ],
      ),
    );
  }
}
