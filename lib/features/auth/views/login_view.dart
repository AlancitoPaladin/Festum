import 'package:festum/app/router/app_routes.dart';
import 'package:festum/core/di/app_locator.dart';
import 'package:festum/core/theme/app_colors.dart';
import 'package:festum/features/auth/utils/auth_validators.dart';
import 'package:festum/features/auth/viewmodels/login_viewmodel.dart';
import 'package:festum/features/auth/widgets/auth_shell.dart';
import 'package:festum/features/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacked/stacked.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return AuthShell(
      middleGradientColor: AppColors.backgroundElevated,
      headerIcon: Icons.lock_person_rounded,
      headerTitle: 'Iniciar sesión',
      headerSubtitle: 'Accede a tu cuenta para continuar.',
      maxWidth: 540,
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
              textInputAction: TextInputAction.done,
              validator: AuthValidators.password,
              onFieldSubmitted: (_) => _submit(context, viewModel),
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
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: viewModel.isBusy ? null : () => _submit(context, viewModel),
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
                    : const Text('Entrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, LoginViewModel viewModel) async {
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
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel(
    locator(),
    locator(),
  );
}
