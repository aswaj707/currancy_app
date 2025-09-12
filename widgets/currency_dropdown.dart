import 'package:flutter/material.dart';
import '../models/currency.dart';

class CurrencyDropdown extends StatelessWidget {
  final Currency? selectedCurrency;
  final List<Currency> currencies;
  final ValueChanged<Currency?> onChanged;
  final String hint;
  final bool isEnabled;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onChanged,
    this.hint = 'Select Currency',
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: isEnabled ? Colors.white : Colors.grey.shade100,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Currency>(
          value: selectedCurrency,
          isExpanded: true,
          isDense: true,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          items: currencies.map((Currency currency) {
            return DropdownMenuItem<Currency>(
              value: currency,
              child: Row(
                children: [
                  Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${currency.code} - ${currency.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }
}
