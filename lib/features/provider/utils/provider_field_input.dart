import 'package:flutter/services.dart';

enum ProviderFieldInputKind {
  title,
  text,
  mixedText,
  integer,
  decimal,
  currency,
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
      case ProviderFieldInputKind.currency:
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
        return <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
      case ProviderFieldInputKind.decimal:
        return <TextInputFormatter>[
          TextInputFormatter.withFunction((oldValue, newValue) {
            if (newValue.text.isEmpty) {
              return newValue;
            }

            final String normalizedText = newValue.text.replaceAll(',', '.');
            final bool isValid = RegExp(
              r'^\d*\.?\d{0,2}$',
            ).hasMatch(normalizedText);

            if (!isValid) {
              return oldValue;
            }

            return TextEditingValue(
              text: normalizedText,
              selection: TextSelection.collapsed(offset: normalizedText.length),
            );
          }),
        ];
      case ProviderFieldInputKind.currency:
        return <TextInputFormatter>[
          TextInputFormatter.withFunction((oldValue, newValue) {
            final String formatted = _formatCurrencyInput(newValue.text);
            return TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
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
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9._@\-]")),
        ];
      case ProviderFieldInputKind.url:
        return <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9:/?&=._\-#%]")),
        ];
    }
  }

  static String _formatCurrencyInput(String rawValue) {
    final String sanitized = rawValue.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (sanitized.isEmpty) {
      return '';
    }

    final int lastDot = sanitized.lastIndexOf('.');
    final int lastComma = sanitized.lastIndexOf(',');
    final int separatorIndex = lastDot > lastComma ? lastDot : lastComma;
    final bool hasSeparator = separatorIndex >= 0;
    final bool hasTrailingSeparator =
        hasSeparator && separatorIndex == sanitized.length - 1;

    final String tailDigits = hasSeparator
        ? sanitized
              .substring(separatorIndex + 1)
              .replaceAll(RegExp(r'[^0-9]'), '')
        : '';
    final bool useDecimalSeparator = hasSeparator && tailDigits.length <= 2;

    String integerDigits =
        (useDecimalSeparator
                ? sanitized.substring(0, separatorIndex)
                : sanitized)
            .replaceAll(RegExp(r'[^0-9]'), '');
    String decimalDigits = useDecimalSeparator ? tailDigits : '';

    if (integerDigits.isEmpty) {
      integerDigits = '0';
    } else {
      integerDigits = integerDigits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    }
    if (decimalDigits.length > 2) {
      decimalDigits = decimalDigits.substring(0, 2);
    }

    final String formattedInteger = _withThousands(integerDigits);
    if (useDecimalSeparator && hasTrailingSeparator && decimalDigits.isEmpty) {
      return '$formattedInteger.';
    }
    if (decimalDigits.isEmpty) {
      return formattedInteger;
    }
    return '$formattedInteger.$decimalDigits';
  }

  static String _withThousands(String digits) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final int reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
