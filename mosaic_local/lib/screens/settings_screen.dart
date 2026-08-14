import 'package:flutter/material.dart';
import '../services/mosaic_engine.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/privacy_badge.dart';

/// Screen for managing on-device LiteRT-LM models, GPU/CPU backends, and offline settings.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.engine,
    required this.onModelChanged,
  });

  final MosaicEngine engine;
  final VoidCallback onModelChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController(
    text:
        'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096.litertlm',
  );
  final TextEditingController _tokenController = TextEditingController();
  bool _working = false;

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = widget.engine.state == EngineState.ready;

    return ListView(
      padding: AppSpacing.screenPadding,
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
              child: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local Model & Engine',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  Text(
                    'Arm hardware acceleration & offline config',
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

        // Model Overview Card
        _buildModelCard(),
        const SizedBox(height: 18),

        if (isReady) ...[
          // Backend Switcher
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: AppSpacing.roundedXl,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARM HARDWARE ACCELERATION',
                  style: AppTypography.badgeLabel.copyWith(
                    color: AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<MosaicBackend>(
                  segments: const [
                    ButtonSegment(
                      value: MosaicBackend.gpu,
                      icon: Icon(Icons.bolt_rounded),
                      label: Text('GPU (Mali / Adreno)'),
                    ),
                    ButtonSegment(
                      value: MosaicBackend.cpu,
                      icon: Icon(Icons.memory_rounded),
                      label: Text('Arm CPU (Neon)'),
                    ),
                  ],
                  selected: {widget.engine.backend},
                  onSelectionChanged: _working
                      ? null
                      : (selection) => _switchBackend(selection.first),
                ),
              ],
            ),
          ),
        ] else ...[
          // Installer Card
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: AppSpacing.roundedXl,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INSTALL ON-DEVICE MODEL',
                  style: AppTypography.badgeLabel.copyWith(
                    color: AppColors.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'Direct .litertlm Model URL',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Hugging Face Token (if gated)',
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _working ? null : _installModel,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.iris,
                  ),
                  icon: _working
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: const Text('Download & Initialize Model'),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        const PrivacyBadge(),
      ],
    );
  }

  Widget _buildModelCard() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.darkCardElevated,
        borderRadius: AppSpacing.roundedXl,
        border: Border.all(
          color: AppColors.iris.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.mint.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.roundedFull,
                ),
                child: const Text(
                  'ARM64 • INT4 QUANTIZED',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.mint,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.engine.state == EngineState.ready
                      ? AppColors.mint
                      : AppColors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.engine.state == EngineState.ready ? 'ONLINE (LOCAL)' : 'SETUP NEEDED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.engine.state == EngineState.ready
                      ? AppColors.mint
                      : AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Gemma 3 1B IT',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.darkTextPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Google LiteRT-LM runtime • 2,048 token context window • Shared across Strategist, Copywriter, and Brand Guardian specialist agents.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _installModel() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _working = true);
    try {
      await widget.engine.installFromNetwork(
        url,
        token: _tokenController.text.trim().isEmpty
            ? null
            : _tokenController.text.trim(),
      );
      widget.onModelChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model installed and ready on Arm!'),
            backgroundColor: AppColors.mintDark,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Installation failed: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _switchBackend(MosaicBackend backend) async {
    setState(() => _working = true);
    try {
      await widget.engine.load(useBackend: backend);
      widget.onModelChanged();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch backend: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }
}
