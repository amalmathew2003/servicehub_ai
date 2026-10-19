import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_bloc.dart';
import 'package:service_hub_ai/features/staff/presentation/bloc/staff_service_state.dart';
import 'package:service_hub_ai/features/staff/presentation/widgets/staff_service_card.dart';

/// A sliver that renders the staff member'"'"'s list of offered services.
/// Handles loading, empty, and loaded states.
class StaffServicesSliver extends StatelessWidget {
  const StaffServicesSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffServiceBloc, StaffServiceState>(
      builder: (context, state) {
        if (state is StaffServiceLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is StaffServicesLoaded && state.services.isNotEmpty) {
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StaffServiceCard(service: state.services[index]),
                );
              }, childCount: state.services.length),
            ),
          );
        }

        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No services yet',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap + to add your first service',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLightSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
