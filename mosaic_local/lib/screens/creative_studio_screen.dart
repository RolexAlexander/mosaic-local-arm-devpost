import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../services/image_generation_engine.dart';
import '../services/mosaic_engine.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/privacy_badge.dart';

/// Creative Studio screen for on-device image generation with Stable Diffusion.
class CreativeStudioScreen extends StatefulWidget {
  const CreativeStudioScreen({
    super.key,
    required this.campaigns,
    required this.textEngine,
    required this.imageEngine,
    required this.onCampaignUpdated,
    this.initialPost,
  });

  final List<Campaign> campaigns;
  final MosaicEngine textEngine;
  final ImageGenerationEngine imageEngine;
  final ValueChanged<Campaign> onCampaignUpdated;
  final CampaignPost? initialPost;

  @override
  State<CreativeStudioScreen> createState() => _CreativeStudioScreenState();
}

class _CreativeStudioScreenState extends State<CreativeStudioScreen> {
  final TextEditingController _modelUrlController = TextEditingController(
    text:
        'https://huggingface.co/Green-Sky/SD-Turbo-GGUF/resolve/main/sd_turbo-f16-q8_0.gguf',
  );
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _negativePromptController = TextEditingController(
    text: 'blurry, distorted, low quality, watermark, text artifacts, extra fingers',
  );
  final TextEditingController _seedController = TextEditingController(text: '-1');

  double _downloadProgress = 0;
  int _steps = 4;
  bool _busy = false;
  ImageGenerationResult? _result;
  CampaignPost? _selectedPost;

  Iterable<CampaignPost> get _allPosts =>
      widget.campaigns.expand((campaign) => campaign.posts);

  @override
  void initState() {
    super.initState();
    if (widget.initialPost != null) {
      _selectPost(widget.initialPost!);
    }
  }

  void _selectPost(CampaignPost post) {
    setState(() {
      _selectedPost = post;
      _promptController.text = post.visual;
    });
  }

  @override
  void dispose() {
    _modelUrlController.dispose();
    _promptController.dispose();
    _negativePromptController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isModelInstalled = widget.imageEngine.modelPath != null;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.mintGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.palette_rounded, color: Color(0xFF0C2B1D), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creative Studio',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  Text(
                    'Arm-powered on-device visual engine',
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
        const SizedBox(height: 18),

        if (!isModelInstalled)
          _buildModelInstaller()
        else
          _buildGenerator(),
      ],
    );
  }

  Widget _buildModelInstaller() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppSpacing.roundedXl,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.15),
              borderRadius: AppSpacing.roundedFull,
            ),
            child: const Text(
              'ON-DEVICE • SD-TURBO GGUF',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.mint,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Install the Visual Model',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'One-time download (~2 GB). Once downloaded, image generation runs completely offline with 0 cloud calls.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _modelUrlController,
            decoration: const InputDecoration(
              labelText: 'GGUF Model Direct URL',
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: AppSpacing.roundedFull,
              child: LinearProgressIndicator(
                value: _downloadProgress == 0 ? null : _downloadProgress,
                color: AppColors.mint,
                backgroundColor: AppColors.darkCardElevated,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(_downloadProgress * 100).toStringAsFixed(0)}% downloaded…',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mintLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _busy ? null : _downloadAndLoadModel,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: AppColors.mintDark,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Install Creative Engine'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_allPosts.isNotEmpty) ...[
          Text(
            'Select Campaign Direction',
            style: AppTypography.badgeLabel.copyWith(
              color: AppColors.darkTextMuted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allPosts.take(6).map((post) {
              final isSelected = _selectedPost == post;
              return ChoiceChip(
                selected: isSelected,
                avatar: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.image_outlined,
                  size: 16,
                  color: isSelected ? AppColors.mint : AppColors.darkTextSecondary,
                ),
                label: Text('Day ${post.day}: ${post.pillar}'),
                onSelected: (_) => _selectPost(post),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        TextField(
          controller: _promptController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Visual Prompt',
            hintText: 'e.g. Modern Caribbean botanical serum bottle on slate counter…',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _negativePromptController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Negative Prompt',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 14),

        // Steps & Seed row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: AppSpacing.roundedLg,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Steps: $_steps',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _steps.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      activeColor: AppColors.mint,
                      onChanged: _busy
                          ? null
                          : (val) => setState(() => _steps = val.round()),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _seedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Seed (-1 for random)',
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        FilledButton.icon(
          onPressed: _busy || _promptController.text.trim().isEmpty
              ? null
              : _generateImage,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: AppColors.iris,
          ),
          icon: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(_busy ? 'Generating on Arm…' : 'Generate 512×512 Visual'),
        ),

        if (_result != null) ...[
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: AppSpacing.roundedXl,
              border: Border.all(color: AppColors.mint.withValues(alpha: 0.4)),
              boxShadow: AppSpacing.mintGlowShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.file(
                    File(_result!.path),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PrivacyBadge(compact: true),
                      const SizedBox(height: 10),
                      Text(
                        '${(_result!.elapsedMs / 1000).toStringAsFixed(1)}s • ${_result!.steps} steps • seed ${_result!.seed} • 0 cloud calls',
                        style: AppTypography.code.copyWith(
                          color: AppColors.mintLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _downloadAndLoadModel() async {
    setState(() => _busy = true);
    try {
      final path = await widget.imageEngine.downloadModel(
        _modelUrlController.text.trim(),
        onProgress: (val) {
          if (mounted) setState(() => _downloadProgress = val);
        },
      );
      await widget.textEngine.unload();
      await widget.imageEngine.initialize(path);
      await widget.imageEngine.release();
      await widget.textEngine.load();
    } catch (error) {
      await widget.imageEngine.release();
      await widget.textEngine.load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _generateImage() async {
    setState(() => _busy = true);
    try {
      await widget.textEngine.unload();
      if (widget.imageEngine.state != CreativeEngineState.ready) {
        await widget.imageEngine.initialize(widget.imageEngine.modelPath!);
      }
      final generated = await widget.imageEngine.generate(
        prompt: _promptController.text.trim(),
        negativePrompt: _negativePromptController.text.trim(),
        steps: _steps,
        cfgScale: 1,
        seed: int.tryParse(_seedController.text) ?? -1,
      );
      await widget.imageEngine.release();
      await widget.textEngine.load();
      _attachToCampaign(generated.path);
      setState(() => _result = generated);
    } catch (error) {
      await widget.imageEngine.release();
      await widget.textEngine.load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image generation failed: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _attachToCampaign(String imagePath) {
    final target = _selectedPost;
    if (target == null) return;
    for (final campaign in widget.campaigns) {
      final index = campaign.posts.indexOf(target);
      if (index < 0) continue;
      final updatedPosts = [...campaign.posts];
      updatedPosts[index] = target.copyWith(imagePath: imagePath);
      widget.onCampaignUpdated(
        campaign.copyWith(
          posts: updatedPosts,
          version: campaign.version + 1,
        ),
      );
      return;
    }
  }
}
