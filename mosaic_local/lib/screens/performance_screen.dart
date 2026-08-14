import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/benchmark.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/metric_tile.dart';
import '../widgets/privacy_badge.dart';

/// Arm performance telemetry and benchmark dashboard.
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key, required this.benchmark});

  final BenchmarkResult? benchmark;

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.speed_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arm Performance',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  Text(
                    'Measured directly on-device • 0 cloud telemetry',
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

        if (benchmark == null)
          _buildEmptyBenchmark()
        else
          _buildTelemetryTiles(benchmark!),

        const SizedBox(height: 20),
        const PrivacyBadge(),
        const SizedBox(height: 20),

        _buildOptimizationStack(),
      ],
    );
  }

  Widget _buildEmptyBenchmark() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppSpacing.roundedXl,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iris.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.speed_rounded,
              size: 36,
              color: AppColors.irisLight,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Benchmark Captured Yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Generate a campaign in the Workspace tab to capture on-device Arm inference metrics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTiles(BenchmarkResult result) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                value: '${result.firstTokenMs}',
                unit: 'ms',
                label: 'First Token Latency',
                icon: Icons.bolt_rounded,
                accentColor: AppColors.irisLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                value: result.estimatedTokensPerSecond.toStringAsFixed(1),
                unit: 'tok/s',
                label: 'Est. Generation Speed',
                icon: Icons.trending_up_rounded,
                accentColor: AppColors.mint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                value: '${result.totalMs}',
                unit: 'ms',
                label: 'Total Latency',
                icon: Icons.timer_outlined,
                accentColor: AppColors.coralLight,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: MetricTile(
                value: '0',
                unit: 'calls',
                label: 'Network Telemetry',
                icon: Icons.shield_outlined,
                accentColor: AppColors.mint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Raw Telemetry JSON viewer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: AppSpacing.roundedLg,
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BENCHMARK TELEMETRY RAW JSON',
                style: AppTypography.badgeLabel.copyWith(
                  color: AppColors.darkTextMuted,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(result.toJson()),
                style: AppTypography.code.copyWith(
                  color: AppColors.mintLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizationStack() {
    final optimizations = [
      '4-bit quantized weights (INT4)',
      'Arm64-only native compilation',
      'LiteRT-LM optimized hardware kernels',
      'GPU-first execution with CPU fallback',
      'Unified weight set shared across agents',
      'Bounded context & token memory budget',
      'Async streaming token output with 0 cloud calls',
    ];

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
          Row(
            children: [
              const Icon(Icons.memory_rounded, size: 20, color: AppColors.irisLight),
              const SizedBox(width: 8),
              Text(
                'Arm Optimization Stack',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final opt in optimizations) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.mint,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      opt,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
