import 'package:flutter/material.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.person,
                size: 55,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 16),

            // Name
            const Text(
              'Staff Name',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Email
            Text(
              'staff@email.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 30),

            // Profile Information
            _ProfileItem(
              icon: Icons.person_outline,
              title: 'Name',
              value: 'Staff Name',
            ),

            _ProfileItem(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'staff@email.com',
            ),

            _ProfileItem(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: 'Not added',
            ),

            _ProfileItem(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: 'Location not available',
            ),

            const SizedBox(height: 20),

            // Online Status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Available for bookings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (value) {
                      // We will connect this to BLoC later.
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // We will implement this later.
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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