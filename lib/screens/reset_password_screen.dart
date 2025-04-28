import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _resetSent = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.requestPasswordReset(
          _emailController.text.trim(),
        );

        setState(() {
          _isLoading = false;
          _resetSent = result;
        });

        if (result && mounted) {
          _showSuccessDialog();
        } else if (mounted) {
          _showErrorDialog();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          _showErrorDialog(e.toString());
        }
      }
    }
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Email envoyé'),
        content: const Text(
          'Un email de réinitialisation a été envoyé à l\'adresse indiquée. Veuillez suivre les instructions pour réinitialiser votre mot de passe.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog([String? message]) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Erreur'),
        content: Text(
          message ??
              'Une erreur s\'est produite lors de l\'envoi de l\'email de réinitialisation. Veuillez réessayer.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Mot de passe oublié'),
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
                  'Réinitialiser le mot de passe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez votre adresse email pour recevoir un lien de réinitialisation',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
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
                      CupertinoTextFormFieldRow(
                        controller: _emailController,
                        prefix: const Icon(CupertinoIcons.mail,
                            color: CupertinoColors.systemGrey),
                        padding: const EdgeInsets.only(bottom: 16),
                        placeholder: "Adresse email",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre adresse email';
                          }
                          if (!_authService.isValidEmail(value)) {
                            return 'Veuillez entrer une adresse email valide';
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
                      const SizedBox(height: 16),
                      Text(
                        'Un email contenant un lien de réinitialisation vous sera envoyé',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : CupertinoButton.filled(
                        onPressed: _requestPasswordReset,
                        child:
                            const Text('Envoyer le lien de réinitialisation'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
