import 'package:flutter/material.dart';

class ClientFeedback {
  const ClientFeedback._();

  static Future<bool> confirmDelete(
    BuildContext context, {
    required String itemLabel,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar del carrito'),
          content: Text('¿Deseas eliminar "$itemLabel"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  static void showMessage(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final bool hasAction = actionLabel != null && onAction != null;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration:
            duration ??
            (hasAction
                ? const Duration(seconds: 5)
                : const Duration(seconds: 3)),
        action: hasAction
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }
}
