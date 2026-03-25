import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/services/auth_state_service.dart';
import 'package:festum/core/services/provider_branding_service.dart';
import 'package:festum/core/services/provider_business_info_state_service.dart';
import 'package:festum/core/services/provider_reactivity_service.dart';
import 'package:festum/core/services/registration_state_service.dart';
import 'package:festum/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class RegistrationViewModel extends BaseViewModel {
  RegistrationViewModel(
    this.role,
    this._authRepository,
    this._authStateService,
    this._registrationStateService,
    this._providerBusinessInfoStateService,
    this._providerBrandingService,
    this._providerReactivityService,
  );

  final AccountRole role;
  final AuthRepository _authRepository;
  final AuthStateService _authStateService;
  final RegistrationStateService _registrationStateService;
  final ProviderBusinessInfoStateService _providerBusinessInfoStateService;
  final ProviderBrandingService _providerBrandingService;
  final ProviderReactivityService _providerReactivityService;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<String?> submit() async {
    setBusy(true);
    try {
      final session = await _authRepository.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        role: role.storageValue,
      );

      if (role == AccountRole.provider) {
        await _providerBusinessInfoStateService.resetBusinessInfoProgress();
      }
      await _providerBrandingService.clear();
      await _providerReactivityService.clear();

      await _registrationStateService.completeRegistration(role);
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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
