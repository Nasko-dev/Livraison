import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/custom_input_field.dart';
// import 'verification_identite_screen.dart';
import 'confirmation_inscription_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  String? _selectedVehicle;
  bool _acceptConditions = false;
  int _currentStep = 0;
  bool _isLoading = false;
  final List<String> _steps = [
    'Informations de base',
    'Coordonnées',
    'Type de véhicule',
    'Documents',
    'Validation'
  ];

  bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return true;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhone(String phone) {
    return phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildStep5();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        CustomInputField(
          controller: _nomController,
          placeholder: 'Nom *',
          icon: CupertinoIcons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le nom est obligatoire';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CustomInputField(
          controller: _prenomController,
          placeholder: 'Prénom *',
          icon: CupertinoIcons.person_2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le prénom est obligatoire';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CustomInputField(
          controller: _emailController,
          placeholder: 'Email *',
          icon: CupertinoIcons.mail,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'email est obligatoire';
            }
            if (!isValidEmail(value)) {
              return 'Format d\'email invalide';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        CustomInputField(
          controller: _telephoneController,
          placeholder: 'Téléphone *',
          icon: CupertinoIcons.phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le numéro de téléphone est obligatoire';
            }
            if (!isValidPhone(value)) {
              return 'Le numéro de téléphone doit contenir 10 chiffres';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CustomInputField(
          controller: _adresseController,
          placeholder: 'Adresse de livraison *',
          icon: CupertinoIcons.location,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'L\'adresse est obligatoire';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildVehicleOption('Scooter', Icons.electric_scooter),
        const SizedBox(height: 12),
        _buildVehicleOption('Voiture', Icons.directions_car),
        const SizedBox(height: 12),
        _buildVehicleOption('Utilitaire/Fourgon', Icons.local_shipping),
      ],
    );
  }

  Widget _buildVehicleOption(String title, IconData icon) {
    final isSelected = _selectedVehicle == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? CupertinoColors.systemBlue.withOpacity(0.1) : null,
          border: Border.all(
            color: isSelected
                ? CupertinoColors.systemBlue
                : CupertinoColors.systemGrey4,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.systemGrey),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : CupertinoColors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        _buildDocumentUpload(
          'Pièce d\'identité',
          CupertinoIcons.doc_text,
          onUpload: () => _uploadDocument('pieceIdentite'),
        ),
        const SizedBox(height: 12),
        _buildDocumentUpload(
          'Permis de conduire',
          CupertinoIcons.doc_text,
          onUpload: () => _uploadDocument('permisConduire'),
        ),
        const SizedBox(height: 12),
        _buildDocumentUpload(
          'Assurance',
          CupertinoIcons.doc_text,
          onUpload: () => _uploadDocument('assurance'),
        ),
        const SizedBox(height: 12),
        _buildDocumentUpload(
          'Attestation SIREN',
          CupertinoIcons.doc_text,
          onUpload: () => _uploadDocument('attestationSiren'),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(String title, IconData icon,
      {required VoidCallback onUpload}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.systemGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onUpload,
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument(String documentType) async {
    // TODO: Implémenter l'upload de document
    // Pour l'instant, on simule juste l'upload
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Document téléchargé'),
          content: const Text('Votre document a été téléchargé avec succès.'),
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

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif de votre inscription',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vérifiez vos informations avant de finaliser votre inscription',
          style: TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 24),
        _buildSummarySection(
          'Informations personnelles',
          [
            _buildSummaryItem('Nom', _nomController.text),
            _buildSummaryItem('Prénom', _prenomController.text),
            if (_emailController.text.isNotEmpty)
              _buildSummaryItem('Email', _emailController.text),
          ],
        ),
        const SizedBox(height: 16),
        _buildSummarySection(
          'Coordonnées',
          [
            _buildSummaryItem('Téléphone', _telephoneController.text),
            _buildSummaryItem('Adresse', _adresseController.text),
          ],
        ),
        const SizedBox(height: 16),
        _buildSummarySection(
          'Véhicule',
          [
            _buildSummaryItem(
                'Type de véhicule', _selectedVehicle ?? 'Non sélectionné'),
          ],
        ),
        const SizedBox(height: 24),
        _buildSummarySection(
          'Documents à fournir',
          [
            _buildDocumentItem('Pièce d\'identité'),
            _buildDocumentItem('Permis de conduire'),
            _buildDocumentItem('Assurance'),
            _buildDocumentItem('Attestation SIREN'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            CupertinoSwitch(
              value: _acceptConditions,
              onChanged: (value) => setState(() => _acceptConditions = value),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'J\'accepte les conditions générales d\'utilisation et je confirme que je dispose de tous les documents requis',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummarySection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.doc_text,
            color: CupertinoColors.systemGrey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Icon(
            CupertinoIcons.checkmark_circle_fill,
            color: CupertinoColors.systemGreen,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      // Le formulaire n'est pas valide
      return;
    }

    // Vérifier si les conditions sont acceptées
    if (!_acceptConditions) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Conditions non acceptées'),
          content: const Text(
              'Veuillez accepter les conditions générales pour continuer.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Début de l\'inscription...');

      final authService = AuthService();

      // Tentative d'inscription
      final user = await authService.registerUser(
        name: _nomController.text.trim(),
        surname: _prenomController.text.trim(),
        phone: _telephoneController.text.trim(),
        address: _adresseController.text.trim(),
        vehicleType: _selectedVehicle?.toLowerCase() ?? '',
        email: _emailController.text.trim(),
      );

      if (user != null && mounted) {
        // Réussite - redirection vers l'écran de confirmation
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => const ConfirmationInscriptionScreen(),
          ),
          (route) => false,
        );
      } else if (mounted) {
        _showErrorDialog('Erreur lors de l\'inscription');
      }
    } catch (e) {
      String errorMessage = e.toString();

      // Traiter les erreurs spécifiques
      if (errorMessage.contains('Email or Username are already taken')) {
        errorMessage = 'Cet email ou numéro de téléphone est déjà utilisé';
      } else if (errorMessage.contains('already taken')) {
        errorMessage = 'Un compte avec ces informations existe déjà';
      } else if (errorMessage.contains('Un compte existe déjà')) {
        errorMessage =
            'Un compte existe déjà avec cet email ou ce numéro de téléphone';
      }

      print('❌ Erreur lors de l\'inscription: $e');
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Erreur d\'inscription'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() => _isLoading = true);
    try {
      // Simuler la vérification du numéro
      await Future.delayed(const Duration(seconds: 1));

      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => PhoneVerificationModal(
          phoneNumber: _telephoneController.text,
          onVerified: (code) async {
            try {
              // Simuler la vérification du code
              await Future.delayed(const Duration(seconds: 1));
              setState(() => _currentStep++);
              Navigator.pop(context);
            } catch (e) {
              if (mounted) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Erreur'),
                    content: Text(e.toString()),
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
          },
          onResendCode: () async {
            try {
              // Simuler l'envoi du code
              await Future.delayed(const Duration(seconds: 1));
              _showCodeSentDialog();
            } catch (e) {
              if (mounted) {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text('Erreur'),
                    content: Text(e.toString()),
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
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Erreur'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCodeSentDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Code renvoyé'),
        content: const Text('Un nouveau code a été envoyé à votre numéro.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showValidationError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Champs manquants'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _validateAndProceed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation spécifique pour chaque étape
    switch (_currentStep) {
      case 0:
        if (_nomController.text.isEmpty ||
            _prenomController.text.isEmpty ||
            _emailController.text.isEmpty) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Champs manquants'),
              content:
                  const Text('Veuillez remplir tous les champs obligatoires.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
          return;
        }
        break;
      case 1:
        if (_telephoneController.text.isEmpty ||
            _adresseController.text.isEmpty) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Champs manquants'),
              content:
                  const Text('Veuillez remplir tous les champs obligatoires.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
          return;
        }
        break;
      case 2:
        if (_selectedVehicle == null) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Type de véhicule manquant'),
              content: const Text('Veuillez sélectionner un type de véhicule.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
          return;
        }
        break;
    }

    setState(() => _currentStep++);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: themeProvider.isDarkMode
          ? CupertinoColors.black
          : CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Inscription'),
        leading: _currentStep > 0
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() => _currentStep--);
                },
                child: const Icon(CupertinoIcons.back),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.back),
              ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Barre de progression
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? CupertinoColors.black
                    : CupertinoColors.systemBackground,
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        _steps.length,
                        (index) => Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: 3,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: index <= _currentStep
                                      ? CupertinoColors.systemBlue
                                      : CupertinoColors.systemGrey4,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _steps[index],
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                  color: index <= _currentStep
                                      ? CupertinoColors.systemBlue
                                      : CupertinoColors.systemGrey,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenu de l'étape
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStepContent(),
                      const SizedBox(height: 32),
                      if (_isLoading)
                        const Center(child: CupertinoActivityIndicator())
                      else
                        CupertinoButton.filled(
                          onPressed: () {
                            if (_currentStep < _steps.length - 1) {
                              _validateAndProceed();
                            } else {
                              _handleRegister();
                            }
                          },
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          borderRadius: BorderRadius.circular(12),
                          child: Text(
                            _currentStep < _steps.length - 1
                                ? 'Continuer'
                                : 'S\'inscrire',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneVerificationModal extends StatefulWidget {
  final String phoneNumber;
  final Function(String) onVerified;
  final VoidCallback onResendCode;

  const PhoneVerificationModal({
    super.key,
    required this.phoneNumber,
    required this.onVerified,
    required this.onResendCode,
  });

  @override
  State<PhoneVerificationModal> createState() => _PhoneVerificationModalState();
}

class _PhoneVerificationModalState extends State<PhoneVerificationModal> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_codeController.text.length != 6) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Code invalide'),
          content: const Text('Veuillez entrer un code à 6 chiffres.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    widget.onVerified(_codeController.text);
    setState(() => _isLoading = false);
  }

  void _handleResendCode() {
    setState(() => _isLoading = true);
    widget.onResendCode();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Vérification du numéro'),
      message: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Un code a été envoyé au ${widget.phoneNumber}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          CupertinoTextField(
            controller: _codeController,
            placeholder: 'Entrez le code',
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              border: Border.all(color: CupertinoColors.systemGrey4),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ],
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: _isLoading ? () {} : _handleVerify,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Vérifier'),
        ),
        CupertinoActionSheetAction(
          onPressed: _isLoading ? () {} : _handleResendCode,
          child: const Text('Renvoyer le code'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: _isLoading ? () {} : () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
    );
  }
}
