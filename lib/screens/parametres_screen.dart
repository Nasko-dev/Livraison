import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool notifications = true;
  String langue = 'Français';

  void _showLangueDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            Text(
              'Choisir la langue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
            const SizedBox(height: 24),
            _buildLangueOption('Français'),
            const Divider(),
            _buildLangueOption('English'),
            const Divider(),
            _buildLangueOption('Español'),
            const Divider(),
            _buildLangueOption('Deutsch'),
            const Spacer(),
            CupertinoButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangueOption(String langueOption) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          langue = langueOption;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              langueOption,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
            const Spacer(),
            if (langue == langueOption)
              const Icon(
                CupertinoIcons.checkmark_alt,
                color: CupertinoColors.systemBlue,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Paramètres'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
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
                    'Préférences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildParametreItem(
                    icon: CupertinoIcons.bell,
                    title: 'Notifications',
                    value: notifications,
                    onChanged: (value) {
                      setState(() {
                        notifications = value;
                      });
                    },
                  ),
                  const Divider(),
                  _buildParametreItem(
                    icon: CupertinoIcons.moon,
                    title: 'Mode sombre',
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  const Divider(),
                  _buildParametreItem(
                    icon: CupertinoIcons.globe,
                    title: 'Langue',
                    value: null,
                    onChanged: null,
                    trailing: Text(
                      langue,
                      style: TextStyle(
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color
                            ?.withOpacity(0.6),
                      ),
                    ),
                    onTap: _showLangueDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
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
                    'À propos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    title: 'Version',
                    value: '1.0.0',
                  ),
                  const Divider(),
                  _buildInfoItem(
                    title: 'Conditions d\'utilisation',
                    value: null,
                    onTap: () {
                      // TODO: Naviguer vers les conditions d'utilisation
                    },
                  ),
                  const Divider(),
                  _buildInfoItem(
                    title: 'Politique de confidentialité',
                    value: null,
                    onTap: () {
                      // TODO: Naviguer vers la politique de confidentialité
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

  Widget _buildParametreItem({
    required IconData icon,
    required String title,
    required bool? value,
    required void Function(bool)? onChanged,
    Widget? trailing,
    VoidCallback? onTap,
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
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
            const Spacer(),
            if (value != null)
              CupertinoSwitch(
                value: value,
                onChanged: onChanged,
              )
            else if (trailing != null)
              trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    String? value,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
            const Spacer(),
            if (value != null)
              Text(
                value,
                style: TextStyle(
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .color
                      ?.withOpacity(0.6),
                ),
              )
            else
              const Icon(
                CupertinoIcons.chevron_right,
                color: CupertinoColors.systemGrey,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
