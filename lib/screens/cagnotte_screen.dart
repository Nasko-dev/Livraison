import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';
import '../providers/balance_provider.dart';

class CagnotteScreen extends StatefulWidget {
  @override
  _CagnotteScreenState createState() => _CagnotteScreenState();
}

class _CagnotteScreenState extends State<CagnotteScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final balanceProvider = Provider.of<BalanceProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ma Cagnotte'),
            const SizedBox(width: 8),
            if (balanceProvider.isLoading)
              const CupertinoActivityIndicator(radius: 8)
            else
              GestureDetector(
                onTap: () => balanceProvider.forceSync(),
                child: Icon(
                  CupertinoIcons.arrow_clockwise,
                  color: themeProvider.isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.activeBlue,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await balanceProvider.syncWithServer();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (balanceProvider.lastSyncTime != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Dernière mise à jour: ${DateFormat('HH:mm:ss').format(balanceProvider.lastSyncTime!)}',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              // ... reste du code existant ...
            ],
          ),
        ),
      ),
    );
  }
}
