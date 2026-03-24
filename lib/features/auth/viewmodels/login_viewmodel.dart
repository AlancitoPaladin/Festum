import 'package:dio/dio.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:festum/features/auth/repositories/auth_repository.dart';
import 'package:festum/features/provider/models/provider_business_profile.dart';
import 'package:festum/features/provider/repositories/provider_business_repository.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class LoginViewModel extends BaseViewModel {
  LoginViewModel(
    this._authRepository,
    this._authStateService,
    this._providerBusinessInfoStateService,
    this._providerBusinessRepository,
  );

  final AuthRepository _authRepository;
  final AuthStateService _authStateService;
  final ProviderBusinessInfoStateService _providerBusinessInfoStateService;
  final ProviderBusinessRepository _providerBusinessRepository;

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

      await _providerBusinessInfoStateService.resetBusinessInfoProgress();
      await _authStateService.signIn(
        accessToken: session.accessToken,
        role: session.role,
        displayName: session.displayName,
      );

      if (session.role == AccountRole.provider) {
        await _syncProviderBusinessInfoProgress();
      }

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

  Future<void> _syncProviderBusinessInfoProgress() async {
    try {
      final ProviderBusinessProfile profile =
          await _providerBusinessRepository.fetchProfile();
      final bool hasCompletedBusinessInfo =
          profile.businessName.trim().isNotEmpty ||
          profile.location.trim().isNotEmpty ||
          profile.coverageArea.trim().isNotEmpty ||
          profile.contactNumber.trim().isNotEmpty ||
          profile.logoUrl.trim().isNotEmpty ||
          profile.photoUrls.isNotEmpty;

      await _providerBusinessInfoStateService.syncBusinessInfoProgress(
        hasCompletedBusinessInfo,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        await _providerBusinessInfoStateService.resetBusinessInfoProgress();
      }
    }
  }
}
