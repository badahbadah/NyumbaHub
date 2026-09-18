import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/conversation_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ConversationService _conversationService = ConversationService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadMessageCount = 0;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  int get unreadMessageCount => _unreadMessageCount;

  Future<bool> register({
    required String fullName, required String phoneNumber, String? email, required String password, required String role,
  }) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      await _apiService.register(fullName: fullName, phoneNumber: phoneNumber, email: email, password: password, role: role);
      _isLoading = false; notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String identifier, required String password}) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    try {
      await _apiService.login(identifier: identifier, password: password);
      final meData = await _apiService.fetchMe();
      _currentUser = AppUser.fromJson(meData['user']);
      _isLoading = false; notifyListeners();
      refreshUnreadCount();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    _unreadMessageCount = 0;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    try {
      final data = await _apiService.fetchMe();
      _currentUser = AppUser.fromJson(data['user']);
      notifyListeners();
      refreshUnreadCount();
    } catch (e) {
      _currentUser = null;
      await _apiService.logout();
    }
  }

  Future<void> refreshUnreadCount() async {
    if (!isLoggedIn) { _unreadMessageCount = 0; notifyListeners(); return; }
    try {
      final count = await _conversationService.fetchUnreadCount();
      _unreadMessageCount = count;
      notifyListeners();
    } catch (_) {}
  }
}