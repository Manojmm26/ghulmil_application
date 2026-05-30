import 'package:flutter/material.dart';
import 'package:ghulmil_application/src/core/theme.dart';

class ServiceCard extends StatelessWidget {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double rating;
  final List<String> tags;
  final String startingPrice;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.rating,
    required this.tags,
    required this.startingPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServiceImage(imageUrl: imageUrl),
            Padding(
              padding: const EdgeInsets.all(spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (subtitle != null) ...[
                    const SizedBox(height: spacingXs),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: spacingSm),
                  Row(
                    children: [
                      const Icon(Icons.star, color: kAccent, size: 16),
                      const SizedBox(width: spacingXs),
                      Text(rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      Text(startingPrice, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: kPrimary)),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: spacingSm),
                    Wrap(
                      spacing: spacingXs,
                      runSpacing: spacingXs,
                      children: tags
                          .take(3)
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: kSurface,
                              labelStyle: Theme.of(context).textTheme.bodySmall,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceImage extends StatelessWidget {
  final String? imageUrl;

  const _ServiceImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        color: kSurface,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported, size: 32, color: Theme.of(context).colorScheme.outline),
      );
    }

    return Image.network(
      imageUrl!,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 120,
          width: double.infinity,
          color: kSurface,
          alignment: Alignment.center,
          child: Icon(Icons.broken_image, size: 32, color: Theme.of(context).colorScheme.error),
        );
      },
    );
  }
}
