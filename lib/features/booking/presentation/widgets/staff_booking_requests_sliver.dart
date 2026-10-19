import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_event.dart';
import 'package:service_hub_ai/features/booking/presentation/bloc/booking_state.dart';
import 'package:service_hub_ai/features/booking/presentation/widgets/staff_booking_card.dart';

/// A sliver that lists all booking requests for the currently signed-in
/// staff member. Handles loading, error, empty, and loaded states.
///
/// After a successful status update ([BookingStatusUpdated]) the sliver
/// automatically reloads the bookings list so the UI stays in sync.
class StaffBookingRequestsSliver extends StatelessWidget {
  const StaffBookingRequestsSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingStatusUpdated) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            context.read<BookingBloc>().add(
              LoadStaffBookingsRequested(staffId: user.uid),
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking status updated'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking error: ${state.message}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          // ── Loading ──
          if (state is BookingLoading) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            );
          }

          // ── Error ──
          if (state is BookingError) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Text(
                  'Could not load bookings. ${state.message}',
                  style: const TextStyle(
                    color: AppColors.textLightSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }

          // ── Not yet loaded ──
          if (state is! StaffBookingsLoaded) {
            return const SliverToBoxAdapter(child: SizedBox(height: 8));
          }

          final bookings = state.bookings;

          // ── Empty ──
          if (bookings.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Text(
                  'No booking requests yet.',
                  style: TextStyle(
                    color: AppColors.textLightSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }

          // ── Loaded ──
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => StaffBookingCard(booking: bookings[index]),
                childCount: bookings.length,
              ),
            ),
          );
        },
      ),
    );
  }
}
