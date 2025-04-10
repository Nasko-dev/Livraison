import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MoyensPaiementScreen extends StatefulWidget {
  const MoyensPaiementScreen({super.key});

  @override
  State<MoyensPaiementScreen> createState() => _MoyensPaiementScreenState();
}

class _MoyensPaiementScreenState extends State<MoyensPaiementScreen> {
  String? iban;
  String? titulaire;
  String? banque;

  void _showAddAccountDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const Text(
                'Ajouter un compte bancaire',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A237E),
                      Color(0xFF283593),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          CupertinoIcons.creditcard,
                          color: CupertinoColors.white,
                          size: 24,
                        ),
                        const Text(
                          'VISA',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '**** **** **** 1234',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TITULAIRE',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              titulaire ?? 'NOM PRENOM',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'EXPIRATION',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 10,
                              ),
                            ),
                            const Text(
                              '12/25',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CupertinoTextField(
                placeholder: 'IBAN',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => iban = value,
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                placeholder: 'Titulaire du compte',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => titulaire = value,
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                placeholder: 'Nom de la banque',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => banque = value,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      color: CupertinoColors.systemGrey5,
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton.filled(
                      onPressed: () {
                        if (iban != null &&
                            titulaire != null &&
                            banque != null) {
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Ajouter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Moyens de paiement'),
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
                    'Cartes bancaires',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCardItem(
                    themeProvider: themeProvider,
                    title: 'Visa •••• 1234',
                    subtitle: 'Expire le 12/25',
                  ),
                  const Divider(),
                  _buildCardItem(
                    themeProvider: themeProvider,
                    title: 'Mastercard •••• 5678',
                    subtitle: 'Expire le 09/24',
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () {
                      // Ajouter une nouvelle carte
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.plus,
                          color: themeProvider.isDarkMode
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ajouter une carte',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemBlue,
                          ),
                        ),
                      ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comptes bancaires',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBankAccountItem(
                    themeProvider: themeProvider,
                    title: 'Compte courant',
                    subtitle: 'FR76 •••• 1234 5678 9012 3456',
                  ),
                  const Divider(),
                  _buildBankAccountItem(
                    themeProvider: themeProvider,
                    title: 'Compte épargne',
                    subtitle: 'FR76 •••• 9876 5432 1098 7654',
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () {
                      // Ajouter un nouveau compte
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.plus,
                          color: themeProvider.isDarkMode
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ajouter un compte',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.systemBlue,
                          ),
                        ),
                      ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historique des paiements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentHistoryItem(
                    themeProvider: themeProvider,
                    title: 'Retrait',
                    amount: '-50,00 €',
                    date: '12/03/2024',
                    isWithdrawal: true,
                  ),
                  const Divider(),
                  _buildPaymentHistoryItem(
                    themeProvider: themeProvider,
                    title: 'Dépôt',
                    amount: '+100,00 €',
                    date: '10/03/2024',
                    isWithdrawal: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem({
    required ThemeProvider themeProvider,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.creditcard,
            color: themeProvider.isDarkMode
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            color: themeProvider.isDarkMode
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountItem({
    required ThemeProvider themeProvider,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.money_dollar,
            color: themeProvider.isDarkMode
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            color: themeProvider.isDarkMode
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem({
    required ThemeProvider themeProvider,
    required String title,
    required String amount,
    required String date,
    required bool isWithdrawal,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isWithdrawal ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
            color: isWithdrawal
                ? CupertinoColors.systemRed
                : CupertinoColors.systemGreen,
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
                Text(
                  date,
                  style: TextStyle(
                    color: themeProvider.isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isWithdrawal
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
