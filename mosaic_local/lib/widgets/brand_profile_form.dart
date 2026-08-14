import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Form for creating and editing the private on-device Brand Profile.
class BrandProfileForm extends StatefulWidget {
  const BrandProfileForm({
    super.key,
    required this.onSaved,
    this.initial,
  });

  final ValueChanged<BrandProfile> onSaved;
  final BrandProfile? initial;

  @override
  State<BrandProfileForm> createState() => _BrandProfileFormState();
}

class _BrandProfileFormState extends State<BrandProfileForm> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _productController =
      TextEditingController(text: widget.initial?.product ?? '');
  late final TextEditingController _audienceController =
      TextEditingController(text: widget.initial?.audience ?? '');
  late final TextEditingController _voiceController =
      TextEditingController(text: widget.initial?.voice ?? '');
  late final TextEditingController _goalController =
      TextEditingController(text: widget.initial?.goal ?? '');
  late final TextEditingController _regionController = TextEditingController(
      text: widget.initial?.region ?? 'Guyana and the Caribbean');

  @override
  void dispose() {
    _nameController.dispose();
    _productController.dispose();
    _audienceController.dispose();
    _voiceController.dispose();
    _goalController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _productController.text.trim().isEmpty) {
      return;
    }

    widget.onSaved(
      BrandProfile(
        name: _nameController.text.trim(),
        product: _productController.text.trim(),
        audience: _audienceController.text.trim().isEmpty
            ? 'Local community & customers'
            : _audienceController.text.trim(),
        voice: _voiceController.text.trim().isEmpty
            ? 'Authentic & friendly'
            : _voiceController.text.trim(),
        goal: _goalController.text.trim().isEmpty
            ? 'Grow brand awareness'
            : _goalController.text.trim(),
        region: _regionController.text.trim().isEmpty
            ? 'Guyana and the Caribbean'
            : _regionController.text.trim(),
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isModal = widget.initial != null;

    return Container(
      padding: AppSpacing.modalPadding,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppSpacing.roundedXxl,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.irisGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isModal ? 'Edit Brand Brain' : 'Create Brand Manifest',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    Text(
                      'Stays 100% private on this device.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Business name',
              hintText: 'e.g. Rainforest Botanicals',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _productController,
            decoration: const InputDecoration(
              labelText: 'What do you sell?',
              hintText: 'e.g. Organic cold-pressed skincare serums',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _audienceController,
            decoration: const InputDecoration(
              labelText: 'Who is it for?',
              hintText: 'e.g. Eco-conscious professionals & travelers',
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voiceController,
                  decoration: const InputDecoration(
                    labelText: 'Brand voice',
                    hintText: 'e.g. Warm, premium',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _regionController,
                  decoration: const InputDecoration(
                    labelText: 'Region context',
                    hintText: 'e.g. Caribbean',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: 'Campaign goal',
              hintText: 'e.g. Drive direct weekend orders',
            ),
          ),
          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.iris,
            ),
            icon: const Icon(Icons.check_rounded),
            label: Text(isModal ? 'Save Brand Updates' : 'Save Private Brand Profile'),
          ),
        ],
      ),
    );
  }
}
