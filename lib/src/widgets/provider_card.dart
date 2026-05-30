import 'package:flutter/material.dart';
import 'package:ghulmil_application/src/core/theme.dart';

class ProviderCard extends StatelessWidget {
  final String id;
  final String name;
  final String photoUrl;
  final double rating;
  final bool verified;
  final List<String> languages;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const ProviderCard({
    super.key,
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.verified,
    required this.languages,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(photoUrl),
            ),
            const SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleMedium),
                      if (verified)
                        const Padding(
                          padding: EdgeInsets.only(left: spacingSm),
                          child: Icon(Icons.verified, color: kSuccess, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: spacingXs),
                  Row(
                    children: [
                      const Icon(Icons.star, color: kAccent, size: 16),
                      Text('$rating (${languages.join(', ')})'),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(onPressed: onMessage, icon: const Icon(Icons.message, color: kPrimary)),
            IconButton(onPressed: onCall, icon: const Icon(Icons.call, color: kPrimary)),
          ],
        ),
      ),
    );
  }
}
