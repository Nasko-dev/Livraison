import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../providers/balance_provider.dart';
import '../models/bank_account.dart';

class MaCagnotteScreen extends StatefulWidget {
  const MaCagnotteScreen({super.key});

  @override
  State<MaCagnotteScreen> createState() => _MaCagnotteScreenState();
}

class _MaCagnotteScreenState extends State<MaCagnotteScreen> {
  final TextEditingController _montantController = TextEditingController();
  BankAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    // S'assurer que les données du BalanceProvider sont chargées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BalanceProvider>(context, listen: false).syncWithServer();
    });
  }

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  void _showRetraitModal() {
    final balanceProvider =
        Provider.of<BalanceProvider>(context, listen: false);
    setState(() {
      _selectedAccount = balanceProvider.selectedAccount;
    });

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        return Container(
          height: MediaQuery.of(context).size.height * 0.5 + bottomPadding,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + bottomPadding,
          ),
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Retrait d\'argent',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.xmark),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Montant à retirer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _montantController,
                placeholder: '0,00 €',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text('€'),
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Compte bancaire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<BalanceProvider>(
                builder: (context, balanceProvider, child) {
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _showBankAccountPicker(context, balanceProvider);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedAccount?.description ??
                                'Sélectionner un compte',
                            style: TextStyle(
                              color: _selectedAccount == null
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.black,
                            ),
                          ),
                          const Icon(CupertinoIcons.chevron_right),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: () => Navigator.of(context).pop(),
                      color: CupertinoColors.systemGrey5,
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<BalanceProvider>(
                      builder: (context, balanceProvider, child) {
                        return CupertinoButton.filled(
                          onPressed: () async {
                            final amount = double.tryParse(
                                _montantController.text.replaceAll(',', '.'));
                            if (amount == null || amount <= 0) {
                              showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                  title: const Text('Erreur'),
                                  content: const Text('Montant invalide'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            if (_selectedAccount == null) {
                              showCupertinoDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                  title: const Text('Erreur'),
                                  content: const Text(
                                      'Veuillez sélectionner un compte bancaire'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('OK'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            // Appeler la méthode withdraw de façon asynchrone
                            final success = await balanceProvider
                                .withdraw(amount, account: _selectedAccount);

                            Navigator.of(context).pop(); // ferme le popup

                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                title: Text(
                                    success ? 'Succès' : 'Solde insuffisant'),
                                content: Text(success
                                    ? 'Vous avez retiré ${amount.toStringAsFixed(2)} € sur ${_selectedAccount!.description}.'
                                    : 'Votre solde est trop faible.'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text('OK'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Valider'),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showBankAccountPicker(
      BuildContext context, BalanceProvider balanceProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey4,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sélectionner un compte',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: balanceProvider.bankAccounts.length,
                  itemBuilder: (context, index) {
                    final account = balanceProvider.bankAccounts[index];
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _selectedAccount = account;
                          balanceProvider.selectBankAccount(account);
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: CupertinoColors.systemGrey4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.bankName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    account.description,
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedAccount?.id == account.id)
                              const Icon(
                                CupertinoIcons.check_mark_circled_solid,
                                color: CupertinoColors.activeBlue,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, BalanceProvider>(
      builder: (context, themeProvider, balanceProvider, child) {
        // Afficher un indicateur de chargement si les données sont en cours de chargement
        if (balanceProvider.isLoading) {
          return CupertinoPageScaffold(
            backgroundColor: themeProvider.isDarkMode
                ? CupertinoColors.black
                : CupertinoColors.systemGroupedBackground,
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Ma cagnotte'),
            ),
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }

        return CupertinoPageScaffold(
          backgroundColor: themeProvider.isDarkMode
              ? CupertinoColors.black
              : CupertinoColors.systemGroupedBackground,
          navigationBar: const CupertinoNavigationBar(
            middle: Text('Ma cagnotte'),
          ),
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await balanceProvider.syncWithServer();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.darkBackgroundGray
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? CupertinoColors.black.withOpacity(0.2)
                              : CupertinoColors.systemGrey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
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
                          '${balanceProvider.balance.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (balanceProvider.selectedAccount != null)
                          Text(
                            'Compte par défaut: ${balanceProvider.selectedAccount!.description}',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.isDarkMode
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 24),
                        CupertinoButton.filled(
                          onPressed: balanceProvider.hasBankAccounts
                              ? _showRetraitModal
                              : null,
                          child: const Text('Retirer'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  if (balanceProvider.history.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Aucune transaction pour le moment',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...balanceProvider.history.map((operation) {
                      // Trouver le compte associé à l'opération s'il existe
                      final account = operation.bankAccountId != null
                          ? balanceProvider
                              .getBankAccountById(operation.bankAccountId!)
                          : null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? CupertinoColors.darkBackgroundGray
                              : CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: themeProvider.isDarkMode
                                  ? CupertinoColors.black.withOpacity(0.2)
                                  : CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              operation.type == OperationType.deposit
                                  ? CupertinoIcons.arrow_down_circle_fill
                                  : CupertinoIcons.arrow_up_circle_fill,
                              color: operation.type == OperationType.deposit
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.destructiveRed,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    operation.type == OperationType.deposit
                                        ? 'Dépôt'
                                        : 'Retrait',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                    ),
                                  ),
                                  if (account != null)
                                    Text(
                                      account.description,
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(operation.date),
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
                              '${operation.type == OperationType.deposit ? '+' : '-'}${operation.amount.toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: operation.type == OperationType.deposit
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.destructiveRed,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
