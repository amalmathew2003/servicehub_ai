
import 'package:flutter/material.dart';
import 'package:service_hub_ai/core/theme/app_colors.dart';

class StaffResultCard extends StatelessWidget {
  final Map<String, dynamic> staff;

  const StaffResultCard({
    super.key,
    required this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final name = staff['name']?.toString() ?? 'Staff member';
    final location =
        staff['location_name']?.toString() ?? 'Location unavailable';

    final distance =
        (staff['distance_km'] as num?)?.toDouble();

    final imageUrl = staff['profile_image']?.toString();

    final services = staff['services'] is List
        ? (staff['services'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : <Map<String, dynamic>>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                backgroundImage: imageUrl != null &&
                        imageUrl.isNotEmpty &&
                        imageUrl != 'null'
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null ||
                        imageUrl.isEmpty ||
                        imageUrl == 'null'
                    ? const Icon(
                        Icons.person_rounded,
                        color: Colors.white70,
                        size: 28,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (distance != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      distance < 1
                          ? '${(distance * 1000).round()} m'
                          : '${distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'away',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: services.map((service) {
                final serviceName =
                    service['name']?.toString() ?? 'Service';

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Staff profile navigation is not connected yet.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person_outline),
              label: const Text('View staff'),
            ),
          ),
        ],
      ),
    );
  }
}
