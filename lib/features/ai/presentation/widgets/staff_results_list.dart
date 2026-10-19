
import 'package:flutter/material.dart';
import 'package:service_hub_ai/features/ai/presentation/widgets/staff_result_card.dart';

class StaffResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> staff;

  const StaffResultsList({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: staff.map((item) {
        return StaffResultCard(staff: item);
      }).toList(),
    );
  }
}
