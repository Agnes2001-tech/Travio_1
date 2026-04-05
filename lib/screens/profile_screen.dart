import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import '../widgets/glass_container.dart';
import '../widgets/stardust_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 22),
              onPressed: () => Fluttertoast.showToast(msg: 'Edit profile'),
            ),
          ),
        ],
      ),
      body: StardustBackground(
        opacity: 0.03,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 54,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=200',
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Agnes Andrea',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'London, United Kingdom',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Travel Management section
              _sectionLabel('TRAVEL MANAGEMENT'),
              _menuTile(
                context,
                icon: Icons.confirmation_number_rounded,
                iconColor: AppColors.primary,
                label: 'My Bookings',
                onTap: () => Fluttertoast.showToast(msg: 'My Bookings'),
              ),
              _menuTile(
                context,
                icon: Icons.favorite_rounded,
                iconColor: Colors.pinkAccent,
                label: 'Favorites',
                onTap: () => Fluttertoast.showToast(msg: 'Favorites'),
              ),
              _menuTile(
                context,
                icon: Icons.credit_card_rounded,
                iconColor: Colors.orangeAccent,
                label: 'Payment Methods',
                onTap: () => Fluttertoast.showToast(msg: 'Payment Methods'),
              ),
              
              const SizedBox(height: 24),

              // Account Settings section
              _sectionLabel('ACCOUNT SETTINGS'),
              _menuTile(
                context,
                icon: Icons.settings_rounded,
                iconColor: AppColors.textSecondary,
                label: 'Settings',
                onTap: () => Fluttertoast.showToast(msg: 'Settings'),
              ),
              _menuTile(
                context,
                icon: Icons.help_center_rounded,
                iconColor: AppColors.textSecondary,
                label: 'Help & Support',
                onTap: () => Fluttertoast.showToast(msg: 'Help & Support'),
              ),
              
              const SizedBox(height: 32),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  borderRadius: 16,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Logout Experience',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
                    onTap: () {
                      Fluttertoast.showToast(msg: 'Logged out!');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.textGrey,
          letterSpacing: 2,
        ),
      ),
    ),
  );

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    child: GlassContainer(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
        onTap: onTap,
      ),
    ),
  );
}
