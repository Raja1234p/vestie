import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'app_shimmer_base.dart';

/// Join requests list skeleton (Week 3 pending memberships).
class JoinRequestsListShimmer extends StatelessWidget {
  const JoinRequestsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 2),
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AppShimmer.box(width: 52, height: 52, borderRadius: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer.box(width: 120, height: 16, borderRadius: 4),
                        const SizedBox(height: 6),
                        AppShimmer.box(width: 80, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppShimmer.box(
                      width: double.infinity,
                      height: 40,
                      borderRadius: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppShimmer.box(
                      width: double.infinity,
                      height: 40,
                      borderRadius: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Member detail body skeleton (`GET …/members/{userId}/activity`).
class MemberDetailShimmer extends StatelessWidget {
  const MemberDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppShimmer.box(width: 54, height: 54, borderRadius: 27),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer.box(width: 140, height: 18, borderRadius: 4),
                    const SizedBox(height: 8),
                    AppShimmer.box(width: 100, height: 14, borderRadius: 4),
                  ],
                ),
              ),
              AppShimmer.box(width: 120, height: 44, borderRadius: 22),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppShimmer.box(
                  width: double.infinity,
                  height: 72,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppShimmer.box(
                  width: double.infinity,
                  height: 72,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppShimmer.box(
                  width: double.infinity,
                  height: 72,
                  borderRadius: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppShimmer.box(width: 180, height: 20, borderRadius: 4),
          const SizedBox(height: 14),
          for (var i = 0; i < 3; i++) ...[
            AppShimmer.box(
              width: double.infinity,
              height: 64,
              borderRadius: 14,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// A premium user profile header skeleton shimmer.
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Row(
        children: [
          AppShimmer.box(width: 80, height: 80, borderRadius: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmer.box(width: 140, height: 20, borderRadius: 4),
              const SizedBox(height: 8),
              AppShimmer.box(width: 180, height: 14, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// Notifications inbox list skeleton.
class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmer.box(width: 48, height: 48, borderRadius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer.box(width: 160, height: 16, borderRadius: 4),
                  const SizedBox(height: 8),
                  AppShimmer.box(
                    width: double.infinity,
                    height: 12,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 4),
                  AppShimmer.box(width: 200, height: 12, borderRadius: 4),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppShimmer.box(width: 40, height: 12, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// Payment methods card list skeleton.
class PaymentCardListShimmer extends StatelessWidget {
  const PaymentCardListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (var i = 0; i < 3; i++) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  AppShimmer.box(width: 40, height: 28, borderRadius: 4),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmer.box(width: 120, height: 16, borderRadius: 4),
                        const SizedBox(height: 6),
                        AppShimmer.box(width: 80, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                  AppShimmer.box(width: 20, height: 20, borderRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Bank account picker rows (withdraw flow).
class BankAccountListShimmer extends StatelessWidget {
  const BankAccountListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => AppShimmer.box(
          width: double.infinity,
          height: 56,
          borderRadius: 12,
        ),
      ),
    );
  }
}

/// KYC / bank Stripe hosted onboarding loading placeholder.
class StripeOnboardingShimmer extends StatelessWidget {
  const StripeOnboardingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppShimmer.box(width: double.infinity, height: 48, borderRadius: 8),
          const SizedBox(height: 16),
          AppShimmer.box(width: double.infinity, height: 120, borderRadius: 8),
          const SizedBox(height: 12),
          AppShimmer.box(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          AppShimmer.box(width: double.infinity, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          AppShimmer.box(width: 240, height: 16, borderRadius: 4),
          const Spacer(),
          AppShimmer.box(width: double.infinity, height: 44, borderRadius: 8),
        ],
      ),
    );
  }
}
