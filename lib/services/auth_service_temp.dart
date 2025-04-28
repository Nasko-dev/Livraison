class AuthService {
  // Simulation de la base de données en mémoire
  final Map<String, Map<String, dynamic>> _users = {};

  // Vérifier le format de l'email
  bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return true; // Email optionnel
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Vérifier le format du téléphone
  bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone);
  }

  // Vérifier si un email est disponible
  Future<bool> isEmailAvailable(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return !_users.values.any((user) => user['email'] == email);
  }

  // Vérifier si un numéro de téléphone est disponible
  Future<bool> isPhoneAvailable(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return !_users.values.any((user) => user['phone'] == phone);
  }

  // Enregistrer un nouvel utilisateur
  Future<void> registerUser({
    required String name,
    required String surname,
    required String phone,
    required String address,
    required String vehicleType,
    String? email,
  }) async {
    // Vérifier la disponibilité du téléphone
    if (!await isPhoneAvailable(phone)) {
      throw 'Ce numéro de téléphone est déjà utilisé';
    }

    // Si un email est fourni, vérifier sa disponibilité
    if (email != null && email.isNotEmpty) {
      if (!await isEmailAvailable(email)) {
        throw 'Cet email est déjà utilisé';
      }
    }

    // Créer un mot de passe temporaire basé sur le téléphone
    final tempPassword = '${phone.substring(0, 3)}${phone.substring(7)}';

    // Stocker les informations de l'utilisateur
    _users[phone] = {
      'name': name,
      'surname': surname,
      'phone': phone,
      'email': email,
      'address': address,
      'vehicleType': vehicleType,
      'password': tempPassword,
      'documents': {
        'identity': false,
        'license': false,
        'insurance': false,
        'siren': false,
      },
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Simuler un délai de traitement
    await Future.delayed(const Duration(seconds: 1));
  }

  // Se connecter avec un numéro de téléphone
  Future<Map<String, dynamic>?> loginWithPhone(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _users[phone];
  }

  // Se connecter avec un email
  Future<Map<String, dynamic>?> loginWithEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _users.values.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }
}
