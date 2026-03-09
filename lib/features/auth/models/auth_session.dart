import 'package:festum/core/models/account_role.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.role,
    this.displayName,
  });

  final String accessToken;
  final AccountRole role;
  final String? displayName;
}
