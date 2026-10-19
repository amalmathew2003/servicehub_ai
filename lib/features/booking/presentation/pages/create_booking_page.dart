
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:service_hub_ai/core/theme/app_colors.dart';
import '../bloc/customer_booking_bloc.dart';
import '../bloc/customer_booking_event.dart';
import '../bloc/customer_booking_state.dart';

class CreateBookingPage extends StatefulWidget {
  final Map<String, dynamic> staff;
  final Map<String, dynamic> service;

  const CreateBookingPage({
    super.key,
    required this.staff,
    required this.service,
  });

  @override
  State<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends State<CreateBookingPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _scheduleForLater = false;
  bool _profileLoading = true;
  bool _submitting = false;
  bool _profileLoaded = false;

  // Load the customer profile when this page opens.
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      context.read<CustomerBookingBloc>().add(
            LoadCustomerProfileRequested(
              userUid: user.uid,
            ),
          );
    } else {
      _profileLoading = false;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: now.add(const Duration(days: 90)),
    );

    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && mounted) {
      setState(() => _selectedTime = time);
    }
  }

  DateTime? _getScheduledDate() {
    if (!_scheduleForLater ||
        _selectedDate == null ||
        _selectedTime == null) {
      return null;
    }

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitBooking() {
    if (_submitting) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in before booking.');
      return;
    }

    if (!_profileLoaded) {
      _showMessage(
        'Your profile is not loaded yet. Please try again.',
      );
      return;
    }

    DateTime? scheduledDate;

    if (_scheduleForLater) {
      if (_selectedDate == null || _selectedTime == null) {
        _showMessage('Please select both a date and time.');
        return;
      }

      scheduledDate = _getScheduledDate();

      if (scheduledDate == null ||
          !scheduledDate.isAfter(DateTime.now())) {
        _showMessage('Please choose a future date and time.');
        return;
      }
    }

    final staffId = widget.staff['staff_id']?.toString() ?? '';
    final staffName =
        widget.staff['name']?.toString() ?? 'Staff member';
    final serviceId = widget.service['service_id']?.toString() ?? '';
    final serviceName =
        widget.service['name']?.toString() ?? 'Service';

    if (staffId.isEmpty || serviceId.isEmpty) {
      _showMessage('Staff or service information is missing.');
      return;
    }

    setState(() => _submitting = true);

    context.read<CustomerBookingBloc>().add(
          SubmitCustomerBookingRequested(
            staffId: staffId,
            staffName: staffName,
            serviceId: serviceId,
            serviceName: serviceName,
            scheduleForLater: _scheduleForLater,
            scheduledDate: scheduledDate,
            staffLatitude:
                (widget.staff['latitude'] as num?)?.toDouble(),
            staffLongitude:
                (widget.staff['longitude'] as num?)?.toDouble(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final staffName =
        widget.staff['name']?.toString() ?? 'Staff member';
    final serviceName =
        widget.service['name']?.toString() ?? 'Service';
    final location =
        widget.staff['location_name']?.toString() ??
            'Location unavailable';
    final imageUrl = widget.staff['profile_image']?.toString();

    return BlocConsumer<CustomerBookingBloc, CustomerBookingState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is CustomerProfileLoaded) {
          setState(() {
            _profileLoaded = true;
            _profileLoading = false;
          });
        } else if (state is CustomerBookingSuccess) {
          setState(() => _submitting = false);
          _showMessage('Booking request submitted successfully.');
          Navigator.of(context).pop();
        } else if (state is CustomerBookingFailure) {
          setState(() {
            _profileLoading = false;
            _submitting = false;
          });
          _showMessage(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text('Book a service'),
            backgroundColor: Colors.transparent,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Your selected professional',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: imageUrl != null &&
                                imageUrl.isNotEmpty &&
                                imageUrl != 'null'
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl == null ||
                                imageUrl.isEmpty ||
                                imageUrl == 'null'
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staffName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              serviceName,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'When do you need the service?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<bool>(
                  groupValue: _scheduleForLater,
                  onChanged: (bool? value) {
                    if (value == null || _submitting) return;
                    setState(() => _scheduleForLater = value);
                  },
                  child: const Column(
                    children: [
                      RadioListTile<bool>(
                        value: false,
                        title: Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Send a booking request now',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      RadioListTile<bool>(
                        value: true,
                        title: Text(
                          'Schedule for Later',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Choose a preferred date and time',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_scheduleForLater) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      _selectedDate == null
                          ? 'Select date'
                          : '${_selectedDate!.day}/'
                              '${_selectedDate!.month}/'
                              '${_selectedDate!.year}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _selectedTime == null
                          ? 'Select time'
                          : _selectedTime!.format(context),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (FirebaseAuth.instance.currentUser == null)
                  const Text(
                    'Please sign in before booking.',
                    style: TextStyle(color: Colors.orangeAccent),
                  )
                else if (_profileLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _submitBooking,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _submitting
                          ? 'Submitting...'
                          : 'Confirm booking',
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
