import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/auth_header.dart';
import '../models/inscription_requirements.dart';

class ConfirmationInscriptionScreen extends StatelessWidget {
  const ConfirmationInscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Inscription confirmée'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Bienvenue !',
                subtitle: 'Votre inscription a été enregistrée avec succès.',
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                        children: [
                          const Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: CupertinoColors.systemGreen,
                            size: 60,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Votre dossier est en cours de traitement',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nous allons vérifier vos documents dans les 24 à 48 heures :',
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoItem(
                            icon: CupertinoIcons.doc_text,
                            title: 'Vos documents',
                            subtitle: 'Permis, carte d\'identité, etc.',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            icon: CupertinoIcons.car_detailed,
                            title: 'Votre véhicule',
                            subtitle: 'Conformité aux exigences',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            icon: CupertinoIcons.person_2,
                            title: 'Votre profil',
                            subtitle: 'Informations personnelles',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                            'Prochaines étapes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStepItem(
                            number: '1',
                            title: 'Vérification des documents',
                            subtitle: 'Dans les 24 à 48 heures',
                          ),
                          const SizedBox(height: 12),
                          _buildStepItem(
                            number: '2',
                            title: 'Réception du colis',
                            subtitle: 'Contenant votre matériel',
                          ),
                          const SizedBox(height: 12),
                          _buildStepItem(
                            number: '3',
                            title: 'Activation du compte',
                            subtitle: 'Vous recevrez un code dans votre colis',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CupertinoButton.filled(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        borderRadius: BorderRadius.circular(12),
                        child: const Text(
                          'Compris',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.systemBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
