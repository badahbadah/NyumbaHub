import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> register({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String identifier, required String password}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    await _apiService.login(identifier: identifier, password: password); // saves the token
    final meData = await _apiService.fetchMe(); // fetch the full profile using that token
    _currentUser = AppUser.fromJson(meData['user']);
    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _errorMessage = e.toString().replaceFirst('Exception: ', '');
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    notifyListeners();
  }

  bool _isCheckingSession = true;
bool get isCheckingSession => _isCheckingSession;

Future<void> checkAuthStatus() async {
  try {
    final data = await _apiService.fetchMe();
    _currentUser = AppUser.fromJson(data['user']);
  } catch (e) {
    _currentUser = null;
    await _apiService.logout(); // clear an invalid/expired token
  } finally {
    _isCheckingSession = false;
    notifyListeners();
  }
}
}