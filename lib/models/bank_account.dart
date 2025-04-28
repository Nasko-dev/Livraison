class BankAccount {
  final int id;
  final String accountNumber;
  final String bankName;
  final String holderName;
  final String type;
  final bool isDefault;

  BankAccount({
    required this.id,
    required this.accountNumber,
    required this.bankName,
    required this.holderName,
    required this.type,
    this.isDefault = false,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      accountNumber: json['accountNumber']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      holderName: json['holderName']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Compte bancaire',
      isDefault: json['isDefault'] == true,
    );
  }

  // Méthode pour masquer le numéro de compte
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '•••• •••• •••• $lastFour';
  }

  // Obtenir une description
  String get description {
    return '$bankName - ${maskedAccountNumber}';
  }
}

// Comptes bancaires par défaut pour le développement
List<BankAccount> getDefaultBankAccounts() {
  return [
    BankAccount(
      id: 1,
      accountNumber: '1234567890123456',
      bankName: 'BNP Paribas',
      holderName: 'John Doe',
      type: 'Compte courant',
      isDefault: true,
    ),
    BankAccount(
      id: 2,
      accountNumber: '9876543210987654',
      bankName: 'Société Générale',
      holderName: 'John Doe',
      type: 'Compte épargne',
    ),
    BankAccount(
      id: 3,
      accountNumber: '5432167890123456',
      bankName: 'PayPal',
      holderName: 'john.doe@example.com',
      type: 'PayPal',
    ),
  ];
}
