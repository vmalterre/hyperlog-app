import 'package:flutter/material.dart';
import 'package:hyperlog/services/auth_service.dart';

class LoginState extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

   // Constructor: Initialize _isLoggedIn
  LoginState() {
    _initializeLoginState();
  }

  // Function to initialize the login state from AuthService
  void _initializeLoginState() async {
    _isLoggedIn = AuthService().isUserLoggedIn();
    notifyListeners(); // Notify listeners after the state is initialized
  }

  void logIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logOut() {
    _isLoggedIn = false;
    notifyListeners();
  }
}