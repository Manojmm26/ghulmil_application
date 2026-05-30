import 'package:flutter/material.dart';
import 'package:ghulmil_application/src/core/theme.dart';

class PackageCard extends StatelessWidget {
  final String id;
  final String title;
  final Duration duration;
  final double price;
  final List<String> inclusions;
  final VoidCallback onSelect;
  final bool isSelected;

  const PackageCard({
    super.key,
    required this.id,
    required this.title,
    required this.duration,
    required this.price,
    required this.inclusions,
    required this.onSelect,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected ? const BorderSide(color: kPrimary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: spacingSm),
              Text('${duration.inHours} hr ${duration.inMinutes.remainder(60)} min',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: spacing),
              ...inclusions.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: spacingSm),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: kSuccess, size: 16),
                        const SizedBox(width: spacingSm),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  )),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Text('\$${price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: kPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
