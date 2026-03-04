import 'package:festum/core/models/account_role.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.role,
  });

  final String accessToken;
  final AccountRole role;
}
