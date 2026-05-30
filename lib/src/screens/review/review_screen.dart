import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/core/constants.dart';
import 'package:ghulmil_application/src/core/theme.dart';
import 'package:go_router/go_router.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const ReviewScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _rating = 0;
  final List<String> _selectedTags = [];
  final _reviewController = TextEditingController();
  double _tipAmount = 0.0;
  bool _includeTip = false;
  bool _rebookSameProvider = false;
  bool _isSubmitting = false;

  final List<String> _availableTags = [
    'Cleanliness',
    'Punctuality',
    'Professionalism',
    'Quality of Work',
    'Communication',
    'Value for Money',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Submit review to API
      await Future.delayed(const Duration(seconds: 1)); // Mock API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(SuccessMessages.reviewSubmitted)),
        );

        // Navigate back to home or show success screen
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ErrorMessages.serverError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = starNumber;
            });
          },
          icon: Icon(
            starNumber <= _rating ? Icons.star : Icons.star_border,
            size: 40,
            color: kAccent,
          ),
        );
      }),
    );
  }

  Widget _buildQuickTags() {
    return Wrap(
      spacing: spacingSm,
      runSpacing: spacingSm,
      children: _availableTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTags.add(tag);
              } else {
                _selectedTags.remove(tag);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTipSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Add Tip (Optional)', style: Theme.of(context).textTheme.titleMedium),
            Switch(
              value: _includeTip,
              onChanged: (value) {
                setState(() {
                  _includeTip = value;
                  if (!value) {
                    _tipAmount = 0.0;
                  }
                });
              },
            ),
          ],
        ),
        if (_includeTip) ...[
          const SizedBox(height: spacing),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _tipAmount,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '\$${_tipAmount.toStringAsFixed(0)}',
                  onChanged: (value) {
                    setState(() {
                      _tipAmount = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: spacing),
              Text(
                '\$${_tipAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: spacingSm),
          Text(
            'Tip helps providers know you appreciate their service',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildRebookSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rebookSameProvider,
                  onChanged: (value) {
                    setState(() {
                      _rebookSameProvider = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Book the same provider again',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (_rebookSameProvider)
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  'We\'ll prioritize this provider for your next booking',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Experience'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitReview,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Section
            Center(
              child: Column(
                children: [
                  Text(
                    'How was your experience?',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: spacing),
                  _buildRatingStars(),
                  if (_rating > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: spacing),
                      child: Text(
                        'You rated: $_rating star${_rating > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: kPrimary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: spacingLg),

            // Quick Tags
            Text('What stood out? (Optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: spacing),
            _buildQuickTags(),
            const SizedBox(height: spacingLg),

            // Review Text
            Text('Share your experience (Optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: spacing),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: 'Tell others about your experience...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: spacingLg),

            // Tip Section
            _buildTipSelector(),
            const SizedBox(height: spacingLg),

            // Rebook Section
            _buildRebookSection(),
            const SizedBox(height: spacingLg),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitReview,
                icon: _isSubmitting ? const SizedBox.shrink() : const Icon(Icons.send),
                label: _isSubmitting
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
