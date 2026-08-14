import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../domain/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Interactive post card for campaign previews, revisions, and approval.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onApproved,
    this.onTapVisual,
  });

  final CampaignPost post;
  final VoidCallback onApproved;
  final VoidCallback? onTapVisual;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imagePath != null && File(post.imagePath!).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppSpacing.roundedXl,
        border: Border.all(
          color: post.approved
              ? AppColors.mint.withValues(alpha: 0.4)
              : AppColors.darkBorder,
          width: post.approved ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual asset if generated
          if (hasImage) ...[
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.file(
                File(post.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day & Pillar Header + Approval Action
                Row(
                  children: [
                    // Day Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: post.day == 1
                            ? AppColors.irisGradient
                            : post.day == 2
                                ? AppColors.coralGradient
                                : AppColors.mintGradient,
                        borderRadius: AppSpacing.roundedFull,
                      ),
                      child: Text(
                        'DAY ${post.day}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: post.day == 3 ? const Color(0xFF072719) : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pillar
                    Text(
                      post.pillar.toUpperCase(),
                      style: AppTypography.badgeLabel.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),

                    const Spacer(),

                    // Copy action
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      tooltip: 'Copy caption',
                      color: AppColors.darkTextSecondary,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: '${post.hook}\n\n${post.caption}\n\n${post.cta}\n${post.hashtags.join(' ')}',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post copy copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    // Approval toggle
                    IconButton.filledTonal(
                      onPressed: onApproved,
                      style: IconButton.styleFrom(
                        backgroundColor: post.approved
                            ? AppColors.mint.withValues(alpha: 0.2)
                            : AppColors.darkCardElevated,
                        foregroundColor: post.approved
                            ? AppColors.mint
                            : AppColors.darkTextMuted,
                      ),
                      icon: Icon(
                        post.approved
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hook
                Text(
                  post.hook,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: AppColors.darkTextPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Caption
                Text(
                  post.caption,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.darkTextSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),

                // Visual Direction Box
                InkWell(
                  onTap: onTapVisual,
                  borderRadius: AppSpacing.roundedSm,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground,
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.brush_outlined,
                          size: 15,
                          color: AppColors.mint,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Visual: ${post.visual}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: AppColors.mintLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // CTA & Hashtags
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'CTA: ${post.cta}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.coralLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.hashtags.join(' '),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.irisLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
