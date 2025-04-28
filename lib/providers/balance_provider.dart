import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/bank_account.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

enum OperationType { withdrawal, deposit }

class Operation {
  final OperationType type;
  final double amount;
  final DateTime date;
  final int? bankAccountId;

  Operation({
    required this.type,
    required this.amount,
    required this.date,
    this.bankAccountId,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      type: json['type'] == 'withdrawal'
          ? OperationType.withdrawal
          : OperationType.deposit,
      amount: double.parse(json['amount'].toString()),
      date: json['processingDate'] != null
          ? DateTime.parse(json['processingDate'])
          : DateTime.parse(json['createdAt']),
      bankAccountId: json['bankAccount']?.toString() != null
          ? int.tryParse(json['bankAccount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type == OperationType.withdrawal ? 'withdrawal' : 'deposit',
      'amount': amount,
      'date': date.toIso8601String(),
      'bankAccountId': bankAccountId,
    };
  }
}

class BalanceProvider with ChangeNotifier {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Timer? _syncTimer;

  double _balance = 0.0; // Commencer avec un solde à 0
  List<Operation> _history = [];
  List<BankAccount> _bankAccounts = [];
  BankAccount? _selectedAccount;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastSyncTime;

  double get balance => _balance;
  List<Operation> get history => List.unmodifiable(_history);
  List<BankAccount> get bankAccounts => List.unmodifiable(_bankAccounts);
  BankAccount? get selectedAccount => _selectedAccount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBankAccounts => _bankAccounts.isNotEmpty;
  DateTime? get lastSyncTime => _lastSyncTime;

  BalanceProvider() {
    _initializeDio();
    _initialize();
    _startAutoSync();
  }

  void _initializeDio() {
    _dio.options.baseUrl =
        'http://192.168.1.102:1337'; // Assurez-vous que l'URL est correcte
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  void _startAutoSync() {
    // Synchroniser toutes les 30 secondes
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      syncWithServer();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Chargement initial des comptes bancaires
    await loadBankAccounts();

    // Synchronisation initiale avec le serveur
    await syncWithServer();
  }

  Future<void> loadBankAccounts() async {
    try {
      final token = await _storage.read(key: 'jwt');
      if (token == null) {
        throw Exception('Token non disponible');
      }

      print('🔄 loadBankAccounts with token: $token');

      final response = await http.get(
        Uri.parse('http://192.168.1.102:1337/api/bank-accounts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📦 Response status: ${response.statusCode}');
      print('📦 Response data: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['data'] != null) {
          _bankAccounts = (data['data'] as List)
              .map((item) => BankAccount.fromJson({
                    'id': item['id'],
                    'accountNumber': item['accountNumber'],
                    'bankName': item['bankName'],
                    'holderName': item['holderName'],
                    'type': item['type'],
                    'isDefault': item['isDefault'],
                  }))
              .toList();
          notifyListeners();
        } else {
          _bankAccounts = [];
          notifyListeners();
        }
      } else {
        throw Exception('Erreur lors du chargement des comptes bancaires');
      }
    } catch (e) {
      print('❌ loadBankAccounts error: $e');
      rethrow;
    }
  }

  void selectBankAccount(BankAccount account) {
    _selectedAccount = account;
    notifyListeners();
  }

  Future<bool> withdraw(double amount, {BankAccount? account}) async {
    try {
      _setLoading(true);
      _clearError();

      // Vérifier que le montant est valide
      if (amount <= 0) {
        _setError("Le montant doit être supérieur à 0");
        return false;
      }

      // Vérifier que le compte est sélectionné
      final targetAccount = account ?? _selectedAccount;
      if (targetAccount == null) {
        _setError("Veuillez sélectionner un compte bancaire");
        return false;
      }

      // Récupérer le token JWT
      final jwt = await _storage.read(key: 'jwt');
      if (jwt == null) {
        _setError("Non authentifié");
        return false;
      }

      print('💸 Tentative de retrait de $amount€');
      print('🏦 Compte sélectionné: ${targetAccount.id}');

      // Appeler l'API pour effectuer le retrait
      final response = await http.post(
        Uri.parse('http://192.168.1.102:1337/api/bank-accounts/withdraw'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'bankAccountId': targetAccount.id,
        }),
      );

      print('📦 Withdraw response: ${response.body}'); // Log pour débogage

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Mettre à jour le solde avec la valeur du serveur
        if (responseData['data'] != null &&
            responseData['data']['newBalance'] != null) {
          setState(() {
            _balance = (responseData['data']['newBalance'] as num).toDouble();
          });
        }

        // Mettre à jour l'historique
        await loadTransactionHistory();
        return true;
      } else {
        final responseData = json.decode(response.body);
        if (responseData['error'] != null) {
          _setError(responseData['error'].toString());
        } else {
          _setError("Erreur lors du retrait");
        }
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors du retrait: $e'); // Log pour débogage
      _setError('Erreur lors du retrait: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTransactionHistory() async {
    try {
      final jwt = await _storage.read(key: 'jwt');
      if (jwt == null) return;

      final response = await http.get(
        Uri.parse('http://192.168.1.102:1337/api/transactions'),
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      print('📦 Transaction history response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['data'] != null) {
          final List<dynamic> transactionsData = data['data'];
          final newHistory = transactionsData
              .map((item) => Operation.fromJson({
                    'id': item['id'],
                    'type': item['type'],
                    'amount': item['amount'],
                    'processingDate': item['processingDate'],
                    'createdAt': item['createdAt'],
                    'bankAccount': item['bankAccount']?['id'],
                  }))
              .toList();

          _history = newHistory;
          notifyListeners();
        }
      } else {
        print('❌ Failed to load transaction history: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading transaction history: $e');
    }
  }

  Future<void> syncWithServer() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Récupérer le token JWT
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      // Récupérer les statistiques des transactions
      final response = await http.get(
        Uri.parse('http://192.168.1.102:1337/api/transactions/stats'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📦 Sync response: ${response.body}'); // Log pour débogage

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Données reçues du serveur: $data'); // Log pour débogage

        // Utiliser directement le solde renvoyé par le serveur
        if (data['data'] != null && data['data']['balance'] != null) {
          setState(() {
            _balance = (data['data']['balance'] as num).toDouble();
          });
        }

        // Charger l'historique des transactions
        await loadTransactionHistory();

        // Charger les comptes bancaires
        await loadBankAccounts();

        // Mettre à jour l'heure de la dernière synchronisation
        _lastSyncTime = DateTime.now();
      } else {
        print('❌ Erreur de synchronisation: ${response.statusCode}');
        throw Exception('Erreur lors de la récupération du solde');
      }
    } catch (e) {
      print('❌ Erreur lors de la synchronisation: $e'); // Log pour débogage
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Forcer une synchronisation manuelle
  Future<void> forceSync() async {
    await syncWithServer();
  }

  // Ajouter un compte bancaire
  Future<void> addBankAccount({
    required String accountNumber,
    required String bankName,
    required String holderName,
    String type = 'Compte bancaire',
  }) async {
    try {
      _setLoading(true);

      final token = await _storage.read(key: "jwt");
      final response = await _dio.post(
        '/api/bank-accounts',
        data: {
          'accountNumber': accountNumber,
          'bankName': bankName,
          'holderName': holderName,
          'type': type,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        // Recharger les comptes bancaires après l'ajout
        await loadBankAccounts();
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de l\'ajout du compte bancaire: $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Définir un compte bancaire par défaut
  Future<void> setDefaultBankAccount(int accountId) async {
    try {
      _setLoading(true);

      final token = await _storage.read(key: "jwt");
      final response = await _dio.put(
        '/api/bank-accounts/$accountId/default',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Mettre à jour les comptes bancaires localement
        final updatedAccounts = bankAccounts.map((account) {
          return BankAccount(
            id: account.id,
            accountNumber: account.accountNumber,
            bankName: account.bankName,
            holderName: account.holderName,
            type: account.type,
            isDefault: account.id == accountId,
          );
        }).toList();

        _bankAccounts = updatedAccounts;
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la définition du compte par défaut: $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer un compte bancaire
  Future<void> deleteBankAccount(int accountId) async {
    try {
      _setLoading(true);

      final token = await _storage.read(key: "jwt");
      final response = await _dio.delete(
        '/api/bank-accounts/$accountId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Supprimer le compte de la liste locale
        _bankAccounts =
            bankAccounts.where((account) => account.id != accountId).toList();
        notifyListeners();
      }
    } catch (error) {
      print('Erreur lors de la suppression du compte bancaire: $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir un compte bancaire par ID
  BankAccount? getBankAccountById(int id) {
    try {
      return _bankAccounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour un compte bancaire
  Future<void> updateBankAccount({
    required int id,
    required String accountNumber,
    required String bankName,
    required String holderName,
    required String type,
  }) async {
    try {
      _setLoading(true);

      final token = await _storage.read(key: "jwt");
      final response = await http.put(
        Uri.parse('http://192.168.1.102:1337/api/bank-accounts/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'data': {
            'accountNumber': accountNumber,
            'bankName': bankName,
            'holderName': holderName,
            'type': type,
          }
        }),
      );

      if (response.statusCode == 200) {
        // Recharger les comptes bancaires après la modification
        await loadBankAccounts();
        notifyListeners();
      } else {
        throw Exception('Erreur lors de la modification du compte bancaire');
      }
    } catch (error) {
      print('Erreur lors de la modification du compte bancaire: $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt');
  }

  void setState(Function() fn) {
    fn();
    notifyListeners();
  }
}
