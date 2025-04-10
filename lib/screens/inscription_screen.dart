import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/custom_input_field.dart';
import '../models/inscription_requirements.dart';
import 'verification_identite_screen.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _mailController = TextEditingController();
  final _numeroSecuController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  String _selectedLanguage = 'Français';
  bool _isFormValid = false;
  bool _acceptConditions = false;

  @override
  void initState() {
    super.initState();
    _nomController.addListener(_validateForm);
    _prenomController.addListener(_validateForm);
    _adresseController.addListener(_validateForm);
    _telephoneController.addListener(_validateForm);
    _mailController.addListener(_validateForm);
    _numeroSecuController.addListener(_validateForm);
    _dateNaissanceController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nomController.text.isNotEmpty &&
          _prenomController.text.isNotEmpty &&
          _adresseController.text.isNotEmpty &&
          _telephoneController.text.isNotEmpty &&
          _mailController.text.isNotEmpty &&
          _numeroSecuController.text.isNotEmpty &&
          _dateNaissanceController.text.isNotEmpty &&
          _acceptConditions;
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _mailController.dispose();
    _numeroSecuController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Création de compte'),
        backgroundColor: CupertinoColors.systemGroupedBackground,
        border: null,
        transitionBetweenRoutes: false,
        automaticallyImplyLeading: true,
        automaticallyImplyMiddle: true,
        padding: EdgeInsetsDirectional.zero,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.systemBlue,
          ),
        ),
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
                CustomInputField(
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
                const SizedBox(height: 12),
                CustomInputField(
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
                const SizedBox(height: 12),
                CustomInputField(
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
                const SizedBox(height: 12),
                CustomInputField(
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
                const SizedBox(height: 12),
                CustomInputField(
                  controller: _mailController,
                  placeholder: 'Email',
                  icon: CupertinoIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  controller: _numeroSecuController,
                  placeholder: 'Numéro de sécurité sociale',
                  icon: CupertinoIcons.doc_text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de sécurité sociale';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  controller: _dateNaissanceController,
                  placeholder: 'Date de naissance (JJ/MM/AAAA)',
                  icon: CupertinoIcons.calendar,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre date de naissance';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conditions générales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...InscriptionRequirements.conditionsGenerales.entries
                          .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                color: CupertinoColors.systemGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(entry.value),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Documents obligatoires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...InscriptionRequirements.documentsObligatoires.entries
                          .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.doc_text,
                                color: CupertinoColors.systemBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(entry.value),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exigences liées au véhicule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...InscriptionRequirements.exigencesVehicule.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.car_detailed,
                                color: CupertinoColors.systemBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(entry.value),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CupertinoSwitch(
                      value: _acceptConditions,
                      onChanged: (value) {
                        setState(() {
                          _acceptConditions = value;
                          _validateForm();
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const Text(
                        'J\'accepte les conditions générales et je confirme que je dispose de tous les documents requis',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CupertinoButton.filled(
                    onPressed: _isFormValid
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const VerificationIdentiteScreen(),
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
