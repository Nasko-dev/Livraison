class InscriptionRequirements {
  static const Map<String, String> conditionsGenerales = {
    'age': 'Avoir au moins 18 ans',
    'telephone': 'Téléphone mobile compatible avec l\'application',
    'email': 'Adresse e-mail valide',
    'numeroSecu': 'Numéro de sécurité sociale',
  };

  static const Map<String, String> documentsObligatoires = {
    'permis': 'Permis de conduire valide',
    'carteIdentite': 'Carte d\'identité en cours de validité',
    'permisTravail': 'Permis de travail (si étranger)',
    'preuveResidence': 'Preuve de résidence (facture, bail...)',
    'assuranceAuto': 'Assurance automobile valide',
  };

  static const Map<String, String> exigencesVehicule = {
    'portes': 'Au moins 2 portes',
    'moteur': 'Moteur 4 cylindres ou plus',
    'assurance': 'Assurance automobile valide',
  };

  static const List<String> etapesInscription = [
    'Télécharger l\'application',
    'Créer un compte',
    'Fournir les documents demandés',
    'Attendre la validation',
  ];
}
