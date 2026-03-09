import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class LoginViewModel extends BaseViewModel {
  LoginViewModel(this._authRepository, this._authStateService);

  final AuthRepository _authRepository;
  final AuthStateService _authStateService;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<String?> submit() async {
    setBusy(true);
    try {
      final session = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await _authStateService.signIn(
        accessToken: session.accessToken,
        role: session.role,
        displayName: session.displayName,
      );
      return null;
    } catch (error) {
      return AuthRepository.mapApiError(error);
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
