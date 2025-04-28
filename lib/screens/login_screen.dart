import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.loginWithCode(
        _phoneController.text.trim(),
        _codeController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Code invalide'),
            content: Text(authProvider.error ?? 'Erreur lors de la connexion'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _goToResetPassword() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ResetPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Connexion'),
        backgroundColor: Color(0xFFF2F2F7),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous avec votre numéro et code',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
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
                      // Téléphone
                      CupertinoTextFormFieldRow(
                        controller: _phoneController,
                        prefix: const Icon(CupertinoIcons.phone,
                            color: CupertinoColors.systemGrey),
                        padding: const EdgeInsets.only(bottom: 16),
                        placeholder: "Numéro de téléphone",
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre numéro de téléphone';
                          }
                          if (value.length != 10) {
                            return 'Le numéro doit contenir 10 chiffres';
                          }
                          return null;
                        },
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  CupertinoColors.systemGrey.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),

                      // Champ de code à 4 chiffres
                      CupertinoTextFormFieldRow(
                        controller: _codeController,
                        prefix: const Icon(CupertinoIcons.number,
                            color: CupertinoColors.systemGrey),
                        padding: const EdgeInsets.only(bottom: 16),
                        placeholder: "Code à 4 chiffres",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre code';
                          }
                          if (value.length != 4) {
                            return 'Le code doit contenir 4 chiffres';
                          }
                          return null;
                        },
                        decoration: const BoxDecoration(),
                      ),

                      // Info bulle pour le code
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.info_circle,
                                color: CupertinoColors.systemBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Utilisez le code à 4 chiffres qui vous a été attribué lors de votre inscription',
                                  style: TextStyle(
                                    color: CupertinoColors.systemBlue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Lien pour mot de passe oublié / Retrouver son code
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _goToResetPassword,
                        child: const Text(
                          'Vous avez oublié votre code ?',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (authProvider.isLoading)
                  const Center(child: CupertinoActivityIndicator())
                else
                  CupertinoButton.filled(
                    onPressed: _login,
                    child: const Text('Se connecter'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
