import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../services/benchmark.dart';
import '../services/mosaic_engine.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/brand_card.dart';
import '../widgets/brand_profile_form.dart';
import '../widgets/generation_pipeline_card.dart';
import '../widgets/privacy_badge.dart';
import '../widgets/product_visual_card.dart';
import '../widgets/social_copy_card.dart';
import '../widgets/strategy_card.dart';

/// The Campaign Workspace screen matching the banner.png mockup.
class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.brand,
    required this.campaigns,
    required this.engine,
    required this.benchmark,
    required this.onBrandSaved,
    required this.onCampaignCreated,
    required this.onNavigateToTab,
  });

  final BrandProfile? brand;
  final List<Campaign> campaigns;
  final MosaicEngine engine;
  final BenchmarkResult? benchmark;
  final ValueChanged<BrandProfile> onBrandSaved;
  final ValueChanged<GenerationOutput> onCampaignCreated;
  final ValueChanged<int> onNavigateToTab;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  bool _generating = false;
  String _stage = '';
  String _preview = '';

  Campaign? get _latestCampaign =>
      widget.campaigns.isNotEmpty ? widget.campaigns.first : null;

  CampaignPost? get _latestPost =>
      _latestCampaign != null && _latestCampaign!.posts.isNotEmpty
          ? _latestCampaign!.posts.first
          : null;

  @override
  Widget build(BuildContext context) {
    final hasBrand = widget.brand != null;
    final isReady = widget.engine.state == EngineState.ready;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // Brand Profile section or Create Form
        if (!hasBrand) ...[
          Text(
            'Build your brand brain.',
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your brand manifest stays 100% on this phone—from strategy to final campaign.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          BrandProfileForm(onSaved: widget.onBrandSaved),
        ] else ...[
          BrandCard(
            profile: widget.brand!,
            onEdit: () => _editBrandModal(context),
          ),
          const SizedBox(height: 22),

          // CAMPAIGN WORKSPACE Header
          Row(
            children: [
              Text(
                'CAMPAIGN WORKSPACE',
                style: AppTypography.sectionHeader.copyWith(
                  color: AppColors.darkTextMuted,
                ),
              ),
              const Spacer(),
              if (_latestCampaign != null)
                Text(
                  _latestCampaign!.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.irisLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Live Generation Pipeline Card
          if (_generating) ...[
            GenerationPipelineCard(stage: _stage, preview: _preview),
            const SizedBox(height: 16),
          ],

          // STRATEGY Card
          StrategyCard(
            brand: widget.brand,
            campaign: _latestCampaign,
            onTap: () => widget.onNavigateToTab(1), // Go to Campaigns
          ),
          const SizedBox(height: 14),

          // SOCIAL COPY Card
          SocialCopyCard(
            brand: widget.brand,
            post: _latestPost,
            onTap: () => widget.onNavigateToTab(1), // Go to Campaigns
          ),
          const SizedBox(height: 14),

          // PRODUCT VISUAL Card
          ProductVisualCard(
            post: _latestPost,
            onTap: () => widget.onNavigateToTab(2), // Go to Creative Studio
          ),
          const SizedBox(height: 20),

          // Primary Generate Action Button
          FilledButton.icon(
            onPressed: isReady && !_generating ? _generateCampaign : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: isReady ? AppColors.iris : AppColors.darkCardElevated,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
              elevation: isReady ? 4 : 0,
              shadowColor: AppColors.irisGlow,
            ),
            icon: _generating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
              _generating
                  ? 'Generating locally on Arm…'
                  : isReady
                      ? (_latestCampaign == null
                          ? 'Generate 3-Post Campaign Locally'
                          : 'Generate New Campaign Revision')
                      : 'Install Local Model to Begin',
            ),
          ),
          const SizedBox(height: 16),

          // Offline & Privacy Banner
          const PrivacyBadge(),
        ],
      ],
    );
  }

  Future<void> _generateCampaign() async {
    if (widget.brand == null) return;

    setState(() {
      _generating = true;
      _preview = '';
      _stage = 'Warming up the Arm LiteRT-LM engine…';
    });

    try {
      final output = await widget.engine.createCampaign(
        widget.brand!,
        onStage: (stage) {
          if (mounted) setState(() => _stage = stage);
        },
        onToken: (token) {
          if (mounted) {
            setState(() {
              _preview += token;
              if (_preview.length > 250) {
                _preview = _preview.substring(_preview.length - 250);
              }
            });
          }
        },
      );

      widget.onCampaignCreated(output);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Campaign "${output.campaign.name}" created and stored locally!'),
            backgroundColor: AppColors.darkCardElevated,
            action: SnackBarAction(
              label: 'View',
              textColor: AppColors.mint,
              onPressed: () => widget.onNavigateToTab(1),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation failed: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }

  void _editBrandModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: BrandProfileForm(
          initial: widget.brand,
          onSaved: widget.onBrandSaved,
        ),
      ),
    );
  }
}
