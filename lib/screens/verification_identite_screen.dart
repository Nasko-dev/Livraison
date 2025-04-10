import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/auth_header.dart';
import '../models/inscription_requirements.dart';
import 'confirmation_inscription_screen.dart';

class VerificationIdentiteScreen extends StatefulWidget {
  const VerificationIdentiteScreen({super.key});

  @override
  State<VerificationIdentiteScreen> createState() =>
      _VerificationIdentiteScreenState();
}

class _VerificationIdentiteScreenState
    extends State<VerificationIdentiteScreen> {
  Map<String, bool> _documentsUploaded = {
    'permis': false,
    'carteIdentite': false,
    'permisTravail': false,
    'preuveResidence': false,
    'assuranceAuto': false,
  };

  bool get _allDocumentsUploaded =>
      _documentsUploaded.values.every((uploaded) => uploaded);

  void _handleDocumentUpload(String documentType) {
    setState(() {
      _documentsUploaded[documentType] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Vérification d\'identité'),
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
          child: Column(
            children: [
              const AuthHeader(
                title: 'Vérification d\'identité',
                subtitle:
                    'Pour votre sécurité et celle de nos clients, nous devons vérifier votre identité.',
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
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
                    const Text(
                      'Documents à télécharger',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...InscriptionRequirements.documentsObligatoires.entries
                        .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              _documentsUploaded[entry.key]!
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons.doc_text,
                              color: _documentsUploaded[entry.key]!
                                  ? CupertinoColors.systemGreen
                                  : CupertinoColors.systemBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(entry.value),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _handleDocumentUpload(entry.key),
                              child: Text(
                                _documentsUploaded[entry.key]!
                                    ? 'Modifier'
                                    : 'Télécharger',
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
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
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
                    const Text(
                      'Exigences liées au véhicule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
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
              Container(
                margin: const EdgeInsets.all(16),
                child: CupertinoButton.filled(
                  onPressed: _allDocumentsUploaded
                      ? () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  const ConfirmationInscriptionScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Valider'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
