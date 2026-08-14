import 'package:flutter/material.dart';
import '../domain/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/post_card.dart';

/// Campaign Library screen displaying generated campaigns, strategies, and posts.
class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({
    super.key,
    required this.campaigns,
    required this.onCampaignUpdated,
    required this.onNavigateToCreative,
  });

  final List<Campaign> campaigns;
  final ValueChanged<Campaign> onCampaignUpdated;
  final ValueChanged<CampaignPost> onNavigateToCreative;

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.darkCardElevated,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: const Icon(
                  Icons.auto_awesome_motion_rounded,
                  size: 34,
                  color: AppColors.irisLight,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Campaigns Generated Yet',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate your first on-device marketing campaign in the Workspace tab.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: campaigns.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        final approvedCount = campaign.posts.where((p) => p.approved).length;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: AppSpacing.roundedXl,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: index == 0,
              tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.irisGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.folder_special_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                campaign.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Text(
                      'v${campaign.version} • ${campaign.posts.length} posts',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: approvedCount == campaign.posts.length
                            ? AppColors.mint.withValues(alpha: 0.18)
                            : AppColors.darkCardElevated,
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Text(
                        '$approvedCount/${campaign.posts.length} approved',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: approvedCount == campaign.posts.length
                              ? AppColors.mint
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                // Strategy container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCardElevated,
                    borderRadius: AppSpacing.roundedLg,
                    border: Border.all(
                      color: AppColors.iris.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CAMPAIGN STRATEGY',
                        style: AppTypography.badgeLabel.copyWith(
                          color: AppColors.irisLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        campaign.strategy,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkTextPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Posts List
                for (var postIndex = 0; postIndex < campaign.posts.length; postIndex++)
                  PostCard(
                    post: campaign.posts[postIndex],
                    onTapVisual: () => onNavigateToCreative(campaign.posts[postIndex]),
                    onApproved: () {
                      final updatedPosts = [...campaign.posts];
                      final current = updatedPosts[postIndex];
                      updatedPosts[postIndex] = current.copyWith(
                        approved: !current.approved,
                      );
                      onCampaignUpdated(
                        campaign.copyWith(
                          posts: updatedPosts,
                          version: campaign.version + 1,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
