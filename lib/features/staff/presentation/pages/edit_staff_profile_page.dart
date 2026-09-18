import 'package:flutter/material.dart';

class EditStaffProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;

  const EditStaffProfilePage({
    super.key,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
  });

  @override
  State<EditStaffProfilePage> createState() =>
      _EditStaffProfilePageState();
}

class _EditStaffProfilePageState
    extends State<EditStaffProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.name,
    );

    _emailController = TextEditingController(
      text: widget.email,
    );

    _phoneController = TextEditingController(
      text: widget.phone ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202124),

      appBar: AppBar(
        backgroundColor: const Color(0xFF24272D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          24,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------
            // Profile Image
            // ------------------------------------------------

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF38242C),
                    backgroundImage:
                        widget.profileImage != null &&
                                widget.profileImage!.isNotEmpty
                            ? NetworkImage(
                                widget.profileImage!,
                              )
                            : null,
                    child:
                        widget.profileImage == null ||
                                widget.profileImage!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFFE92D5B),
                              )
                            : null,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE92D5B),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 19,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Profile image selection
                          // will be implemented later.
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ------------------------------------------------
            // Name
            // ------------------------------------------------

            const Text(
              'Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: _inputDecoration(
                hintText: 'Enter your name',
                icon: Icons.person_outline,
              ),
            ),

            const SizedBox(height: 22),

            // ------------------------------------------------
            // Email
            // ------------------------------------------------

            const Text(
              'Email',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _emailController,
              readOnly: true,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              decoration: _inputDecoration(
                hintText: 'Email',
                icon: Icons.email_outlined,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Email cannot be changed',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 22),

            // ------------------------------------------------
            // Phone
            // ------------------------------------------------

            const Text(
              'Phone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: _inputDecoration(
                hintText: 'Enter your phone number',
                icon: Icons.phone_outlined,
              ),
            ),

            const SizedBox(height: 35),

            // ------------------------------------------------
            // Save Button
            // ------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Firebase update will be implemented next.
                },
                icon: const Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE92D5B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade600,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFE92D5B),
      ),
      filled: true,
      fillColor: const Color(0xFF292B30),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade800,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Color(0xFFE92D5B),
          width: 1.5,
        ),
      ),
    );
  }
}