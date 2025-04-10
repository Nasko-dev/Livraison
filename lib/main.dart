import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; // Import nécessaire
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'screens/mission_details_screen.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false; // ajoute cette ligne
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoApp(
      title: 'Livraison Pièces',
      theme: themeProvider.theme,
      home: const MainScreen(),
    );
  }
}

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _mailController = TextEditingController();
  String _selectedLanguage = 'Français';
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nomController.addListener(_validateForm);
    _prenomController.addListener(_validateForm);
    _adresseController.addListener(_validateForm);
    _telephoneController.addListener(_validateForm);
    _mailController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nomController.text.isNotEmpty &&
          _prenomController.text.isNotEmpty &&
          _adresseController.text.isNotEmpty &&
          _telephoneController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        prefix: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(icon, color: CupertinoColors.systemGrey, size: 20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.systemGrey.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 16, color: CupertinoColors.label),
        placeholderStyle: TextStyle(
          color: CupertinoColors.systemGrey.withOpacity(0.8),
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Création de compte'),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildInputField(
                  controller: _nomController,
                  placeholder: 'Nom',
                  icon: CupertinoIcons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _prenomController,
                  placeholder: 'Prénom',
                  icon: CupertinoIcons.person_2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre prénom';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _adresseController,
                  placeholder: 'Adresse',
                  icon: CupertinoIcons.location,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre adresse';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _telephoneController,
                  placeholder: 'Téléphone',
                  icon: CupertinoIcons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de téléphone';
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  controller: _mailController,
                  placeholder: 'Email (facultatif)',
                  icon: CupertinoIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CupertinoFormRow(
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        CupertinoIcons.globe,
                        color: CupertinoColors.systemGrey,
                        size: 20,
                      ),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedLanguage,
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoActionSheet(
                            actions: [
                              CupertinoActionSheetAction(
                                child: const Text('Français'),
                                onPressed: () {
                                  setState(
                                    () => _selectedLanguage = 'Français',
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('English'),
                                onPressed: () {
                                  setState(
                                    () => _selectedLanguage = 'English',
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: const Text('Español'),
                                onPressed: () {
                                  setState(
                                    () => _selectedLanguage = 'Español',
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              child: const Text('Annuler'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CupertinoButton.filled(
                    onPressed: _isFormValid
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('Inscription'),
                                  content: const Text(
                                    'Votre compte est en cours de création...',
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
                          }
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(12),
                    child: const Text(
                      'S\'inscrire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
