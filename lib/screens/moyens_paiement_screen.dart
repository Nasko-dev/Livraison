import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../providers/balance_provider.dart';
import '../models/bank_account.dart';

class MoyensPaiementScreen extends StatefulWidget {
  const MoyensPaiementScreen({super.key});

  @override
  State<MoyensPaiementScreen> createState() => _MoyensPaiementScreenState();
}

class _MoyensPaiementScreenState extends State<MoyensPaiementScreen> {
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  String _selectedAccountType = 'checking';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Synchroniser avec le serveur pour récupérer les comptes bancaires et l'historique
    await Provider.of<BalanceProvider>(context, listen: false).syncWithServer();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _holderNameController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _showAddAccountDialog() {
    // Réinitialiser les contrôleurs
    _ibanController.clear();
    _holderNameController.clear();
    _bankNameController.clear();
    _selectedAccountType = 'checking';

    final balanceProvider =
        Provider.of<BalanceProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

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
                          'IBAN',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _ibanController.text.isEmpty
                          ? '**** **** **** ****'
                          : _maskIban(_ibanController.text),
                      style: const TextStyle(
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
                              _holderNameController.text.isEmpty
                                  ? 'NOM PRENOM'
                                  : _holderNameController.text.toUpperCase(),
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
                              'BANQUE',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _bankNameController.text.isEmpty
                                  ? 'BANQUE'
                                  : _bankNameController.text.toUpperCase(),
                              style: const TextStyle(
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
                controller: _ibanController,
                placeholder: 'IBAN (FR76...)',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _holderNameController,
                placeholder: 'Titulaire du compte',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _bankNameController,
                placeholder: 'Nom de la banque',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('Type de compte:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: _selectedAccountType,
                        children: const {
                          'checking': Text('Courant'),
                          'savings': Text('Épargne'),
                          'credit_card': Text('Carte'),
                          'paypal': Text('PayPal'),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedAccountType = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                    child: Consumer<BalanceProvider>(
                      builder: (context, balanceProvider, child) {
                        return CupertinoButton.filled(
                          onPressed: balanceProvider.isLoading
                              ? null
                              : () async {
                                  if (_ibanController.text.isNotEmpty &&
                                      _holderNameController.text.isNotEmpty &&
                                      _bankNameController.text.isNotEmpty) {
                                    try {
                                      // Ajouter le compte bancaire
                                      await balanceProvider.addBankAccount(
                                        accountNumber: _ibanController.text,
                                        bankName: _bankNameController.text,
                                        holderName: _holderNameController.text,
                                        type: _selectedAccountType,
                                      );

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        // Afficher une confirmation
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CupertinoAlertDialog(
                                            title: const Text('Succès'),
                                            content: const Text(
                                                'Compte bancaire ajouté avec succès'),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('OK'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CupertinoAlertDialog(
                                            title: const Text('Erreur serveur'),
                                            content: Text(
                                                'Une erreur s\'est produite: ${e.toString()}'),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('OK'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // Afficher une alerte si des champs sont vides
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          CupertinoAlertDialog(
                                        title: const Text('Champs incomplets'),
                                        content: const Text(
                                            'Veuillez remplir tous les champs.'),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text('OK'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                          child: balanceProvider.isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text('Ajouter'),
                        );
                      },
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

  // Fonction pour masquer une partie de l'IBAN
  String _maskIban(String iban) {
    if (iban.length <= 8) return iban;
    final visibleStart = iban.substring(0, 4);
    final visibleEnd = iban.substring(iban.length - 4);
    final maskedPart = '•' * (iban.length - 8);
    return '$visibleStart$maskedPart$visibleEnd';
  }

  // Fonction pour formater l'IBAN
  String _formatIban(String iban) {
    if (iban.length <= 4) return iban;
    final visibleStart = iban.substring(0, 4);
    return '$visibleStart •••• •••• •••• ${iban.substring(iban.length - 4)}';
  }

  void _showBankAccountOptions(BankAccount account) {
    final balanceProvider =
        Provider.of<BalanceProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(account.description),
        message: const Text('Que souhaitez-vous faire avec ce compte?'),
        actions: [
          if (!account.isDefault)
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                await balanceProvider.setDefaultBankAccount(account.id);
              },
              child: const Text('Définir comme compte par défaut'),
            ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await balanceProvider.deleteBankAccount(account.id);
            },
            isDestructiveAction: true,
            child: const Text('Supprimer ce compte'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ),
    );
  }

  void _showEditAccountDialog(BankAccount account) {
    // Pré-remplir les champs avec les données du compte
    _ibanController.text = account.accountNumber;
    _holderNameController.text = account.holderName;
    _bankNameController.text = account.bankName;
    _selectedAccountType = account.type;

    final balanceProvider =
        Provider.of<BalanceProvider>(context, listen: false);

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
                'Modifier le compte bancaire',
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
                          'IBAN',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _ibanController.text.isEmpty
                          ? '**** **** **** ****'
                          : _maskIban(_ibanController.text),
                      style: const TextStyle(
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
                              _holderNameController.text.isEmpty
                                  ? 'NOM PRENOM'
                                  : _holderNameController.text.toUpperCase(),
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
                              'BANQUE',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _bankNameController.text.isEmpty
                                  ? 'BANQUE'
                                  : _bankNameController.text.toUpperCase(),
                              style: const TextStyle(
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
                controller: _ibanController,
                placeholder: 'IBAN (FR76...)',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _holderNameController,
                placeholder: 'Titulaire du compte',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _bankNameController,
                placeholder: 'Nom de la banque',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('Type de compte:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoSlidingSegmentedControl<String>(
                        groupValue: _selectedAccountType,
                        children: const {
                          'checking': Text('Courant'),
                          'savings': Text('Épargne'),
                          'credit_card': Text('Carte'),
                          'paypal': Text('PayPal'),
                        },
                        onValueChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedAccountType = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
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
                    child: Consumer<BalanceProvider>(
                      builder: (context, balanceProvider, child) {
                        return CupertinoButton.filled(
                          onPressed: balanceProvider.isLoading
                              ? null
                              : () async {
                                  if (_ibanController.text.isNotEmpty &&
                                      _holderNameController.text.isNotEmpty &&
                                      _bankNameController.text.isNotEmpty) {
                                    try {
                                      // Mettre à jour le compte bancaire
                                      await balanceProvider.updateBankAccount(
                                        id: account.id,
                                        accountNumber: _ibanController.text,
                                        bankName: _bankNameController.text,
                                        holderName: _holderNameController.text,
                                        type: _selectedAccountType,
                                      );

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        // Afficher une confirmation
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CupertinoAlertDialog(
                                            title: const Text('Succès'),
                                            content: const Text(
                                                'Compte bancaire modifié avec succès'),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('OK'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                          Navigator.pop(context);
                                        showCupertinoDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              CupertinoAlertDialog(
                                            title: const Text('Erreur serveur'),
                                            content: Text(
                                                'Une erreur s\'est produite: ${e.toString()}'),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: const Text('OK'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // Afficher une alerte si des champs sont vides
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          CupertinoAlertDialog(
                                        title: const Text('Champs incomplets'),
                                        content: const Text(
                                            'Veuillez remplir tous les champs.'),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text('OK'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                          child: balanceProvider.isLoading
                              ? const CupertinoActivityIndicator()
                              : const Text('Modifier'),
                        );
                      },
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
        child: Consumer<BalanceProvider>(
          builder: (context, balanceProvider, child) {
            if (balanceProvider.isLoading) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await balanceProvider.loadBankAccounts();
                await balanceProvider.syncWithServer();
              },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
                  _buildBankAccounts(),
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
                        if (balanceProvider.history.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Aucune transaction',
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ),
                          )
                        else
                          ...balanceProvider.history.take(5).map((operation) {
                            final isLast =
                                balanceProvider.history.take(5).last ==
                                    operation;

                            String title;
                            if (operation.type == OperationType.withdrawal) {
                              // Rechercher le compte bancaire utilisé pour ce retrait
                              final bankAccount =
                                  operation.bankAccountId != null
                                      ? balanceProvider.getBankAccountById(
                                          operation.bankAccountId!)
                                      : null;

                              title = bankAccount != null
                                  ? 'Retrait vers ${bankAccount.bankName}'
                                  : 'Retrait';
                            } else {
                              title = 'Dépôt';
                            }

                            return Column(
                              children: [
                                _buildPaymentHistoryItem(
                                  themeProvider: themeProvider,
                                  title: title,
                                  amount:
                                      '${operation.type == OperationType.withdrawal ? '-' : '+'}${operation.amount.toStringAsFixed(2)} €',
                                  date: DateFormat('dd/MM/yyyy')
                                      .format(operation.date),
                                  isWithdrawal: operation.type ==
                                      OperationType.withdrawal,
                                ),
                                if (!isLast) const Divider(),
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBankAccounts() {
    return Consumer<BalanceProvider>(
      builder: (context, balanceProvider, child) {
        return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                children: [
                  Text(
                    'Comptes bancaires',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(width: 8),
                      if (balanceProvider.isLoading)
                        const CupertinoActivityIndicator(radius: 8)
                      else
                        GestureDetector(
                          onTap: () => balanceProvider.forceSync(),
                          child: Icon(
                            CupertinoIcons.arrow_clockwise,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _showAddAccountDialog,
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.add,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (balanceProvider.lastSyncTime != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4),
                child: Text(
                  'Dernière synchronisation: ${DateFormat('HH:mm:ss').format(balanceProvider.lastSyncTime!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            if (balanceProvider.bankAccounts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Aucun compte bancaire enregistré',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: balanceProvider.bankAccounts.length,
                itemBuilder: (context, index) {
                  final account = balanceProvider.bankAccounts[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            title: Text(account.bankName),
                            message: Text(
                                '${account.holderName} • ${account.accountNumber}'),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showEditAccountDialog(account);
                                },
                                child: const Text('Modifier'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final confirmed = await showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Confirmation'),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer ce compte ?'),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('Annuler'),
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          child: const Text('Supprimer'),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                  ),
                ],
              ),
                                  );
                                  if (confirmed == true) {
                                    await balanceProvider
                                        .deleteBankAccount(account.id);
                                  }
                                },
                                isDestructiveAction: true,
                                child: const Text('Supprimer'),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annuler'),
        ),
      ),
    );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                                    account.bankName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                Text(
                                    '${account.holderName} • ${account.accountNumber}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
                            if (account.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Défaut',
                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 12,
                                  ),
                  ),
                ),
              ],
            ),
          ),
                    ),
                  );
                },
              ),
          ],
        );
      },
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
