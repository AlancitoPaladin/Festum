import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/models/account_role.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/auth/utils/auth_validators.dart';
import 'package:festum/features/auth/viewmodels/registration_viewmodel.dart';
import 'package:festum/features/auth/widgets/auth_shell.dart';
import 'package:festum/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class RegistrationView extends StackedView<RegistrationViewModel> {
  const RegistrationView({
    required this.role,
    super.key,
  });

  final AccountRole role;

  @override
  Widget builder(
    BuildContext context,
    RegistrationViewModel viewModel,
    Widget? child,
  ) {
    final bool isProvider = role == AccountRole.provider;

    return AuthShell(
      middleGradientColor:
          isProvider ? AppColors.primaryButton : AppColors.backgroundElevated,
      headerIcon:
          isProvider ? Icons.business_center_rounded : Icons.person_rounded,
      headerTitle: isProvider ? 'Registro de proveedor' : 'Registro de cliente',
      headerSubtitle: 'Completa tus datos para continuar a inicio de sesión.',
      maxWidth: 580,
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AuthTextField(
              controller: viewModel.firstNameController,
              label: 'Nombre',
              textInputAction: TextInputAction.next,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: viewModel.lastNameController,
              label: 'Apellidos',
              textInputAction: TextInputAction.next,
              validator: AuthValidators.requiredField,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: viewModel.emailController,
              label: 'Correo electrónico',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: viewModel.passwordController,
              label: 'Contraseña',
              obscureText: viewModel.obscurePassword,
              textInputAction: TextInputAction.next,
              validator: AuthValidators.password,
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.activeIcon,
                ),
                onPressed: viewModel.togglePasswordVisibility,
              ),
            ),
            const SizedBox(height: 12),
            AuthTextField(
              controller: viewModel.confirmPasswordController,
              label: 'Confirmar contraseña',
              obscureText: viewModel.obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: (String? value) => AuthValidators.confirmPassword(
                value,
                originalPassword: viewModel.passwordController.text,
              ),
              onFieldSubmitted: (_) => _submit(context, viewModel),
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.activeIcon,
                ),
                onPressed: viewModel.toggleConfirmPasswordVisibility,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: viewModel.isBusy
                    ? null
                    : () => _submit(context, viewModel),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear cuenta'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: viewModel.isBusy ? null : () => context.go(AppRoutes.login),
              child: const Text('Ya tengo una cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    RegistrationViewModel viewModel,
  ) async {
    if (!viewModel.formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final String? error = await viewModel.submit();
    if (!context.mounted) {
      return;
    }

    if (error == null) {
      context.go(AppRoutes.home);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.alert,
        content: Text(error),
      ),
    );
  }

  @override
  RegistrationViewModel viewModelBuilder(BuildContext context) =>
      RegistrationViewModel(
        role,
        locator(),
        locator(),
        locator(),
      );
}
