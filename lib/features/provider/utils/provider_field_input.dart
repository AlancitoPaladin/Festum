import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ProviderFieldInputKind {
  title,
  text,
  mixedText,
  integer,
  decimal,
  phone,
  socialHandle,
  url,
}

class ProviderFieldInput {
  const ProviderFieldInput._();

  static TextInputType keyboardType(
    ProviderFieldInputKind kind, {
    int maxLines = 1,
  }) {
    switch (kind) {
      case ProviderFieldInputKind.integer:
        return TextInputType.number;
      case ProviderFieldInputKind.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case ProviderFieldInputKind.phone:
        return TextInputType.phone;
      case ProviderFieldInputKind.url:
        return TextInputType.url;
      case ProviderFieldInputKind.title:
      case ProviderFieldInputKind.text:
      case ProviderFieldInputKind.mixedText:
      case ProviderFieldInputKind.socialHandle:
        return maxLines > 1 ? TextInputType.multiline : TextInputType.text;
    }
  }

  static List<TextInputFormatter> formatters(ProviderFieldInputKind kind) {
    switch (kind) {
      case ProviderFieldInputKind.title:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-Z0-9ÁÉÍÓÚáéíóúÑñÜü\s&().,'/-]"),
          ),
        ];
      case ProviderFieldInputKind.text:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-ZÁÉÍÓÚáéíóúÑñÜü\s&().,'/-]"),
          ),
        ];
      case ProviderFieldInputKind.mixedText:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-Z0-9ÁÉÍÓÚáéíóúÑñÜü\s.,;:¿?¡!&@#%()_'/+\-]"),
          ),
        ];
      case ProviderFieldInputKind.integer:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ];
      case ProviderFieldInputKind.decimal:
        return <TextInputFormatter>[
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) {
              return newValue;
            }

            final String normalizedText = newValue.text.replaceAll(',', '.');
            final bool isValid = RegExp(r'^\d*\.?\d{0,2}$').hasMatch(
              normalizedText,
            );

            if (!isValid) {
              return oldValue;
            }

            return TextEditingValue(
              text: normalizedText,
              selection: TextSelection.collapsed(
                offset: normalizedText.length,
              ),
            );
          }),
        ];
      case ProviderFieldInputKind.phone:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(15),
        ];
      case ProviderFieldInputKind.socialHandle:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-Z0-9._@\-]"),
          ),
        ];
      case ProviderFieldInputKind.url:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
            RegExp(r"[a-zA-Z0-9:/?&=._\-#%]"),
          ),
        ];
    }
  }
}
