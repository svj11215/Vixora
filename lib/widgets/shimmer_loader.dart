/// Shimmer loading skeletons for request cards.
library;

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vixora/core/theme/app_theme.dart';

/// A single shimmer skeleton card mimicking VisitorRequestCard dimensions.
class ShimmerRequestCard extends StatelessWidget {
  const ShimmerRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDark,
      highlightColor: AppColors.surfaceElevated,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo skeleton
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Phone
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Purpose
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Time
                  Container(
                    width: 140,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of shimmer request cards.
class ShimmerList extends StatelessWidget {
  final int count;

  const ShimmerList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      itemCount: count,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: ShimmerRequestCard(),
      ),
    );
  }
}
