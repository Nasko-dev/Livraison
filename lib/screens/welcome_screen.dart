import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'inscription_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Image.asset(
                    'assets/images/image.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Livraison Pièces',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Livrez des pièces détachées en toute simplicité',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  CupertinoButton.filled(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const InscriptionScreen(),
                        ),
                      );
                    },
                    child: const Text('Créer un compte'),
                  ),
                  const SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Se connecter'),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => CupertinoActionSheet(
                          title: const Text('Choisir la langue'),
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () {
                                setState(
                                  () => _selectedLanguage = 'Français',
                                );
                                Navigator.pop(context);
                              },
                              child: const Text('Français'),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                setState(
                                  () => _selectedLanguage = 'English',
                                );
                                Navigator.pop(context);
                              },
                              child: const Text('English'),
                            ),
                            CupertinoActionSheetAction(
                              onPressed: () {
                                setState(
                                  () => _selectedLanguage = 'Español',
                                );
                                Navigator.pop(context);
                              },
                              child: const Text('Español'),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.globe,
                          color: CupertinoColors.systemGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLanguage,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
