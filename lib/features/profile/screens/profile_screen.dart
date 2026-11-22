import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../data/local_storage/local_store.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_picker_modal.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final completeness = profileState.completenessPercentage;
    final feedback = profileState.completenessFeedback;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.primaryIndigo,
              size: 26,
            ),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isDark = ref.watch(themeProvider) == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: AppColors.primaryIndigo,
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // 1. Profile Completeness Meter (FR-1.5 Bonus)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          color: AppColors.primaryIndigo,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Profile Completeness Meter',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$completeness%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: completeness == 100
                            ? AppColors.accentEmerald
                            : AppColors.primaryIndigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: completeness / 100.0,
                    backgroundColor: AppColors.slateLight,
                    color: completeness == 100
                        ? AppColors.accentEmerald
                        : AppColors.primaryIndigo,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feedback,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.secondarySlate,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Profile Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                // Avatar with change button
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AvatarWidget(
                      avatarKey: profile.avatar,
                      name: profile.name,
                      radius: 44,
                    ),
                    InkWell(
                      onTap: () => AvatarPickerModal.show(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryIndigo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.department} • Semester ${profile.semester}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigoLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.projectType,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryIndigoDark,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),

                // Availability
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.secondarySlate,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Availability: ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        profile.availability,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bio
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    profile.bio,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Technical Skills Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Technical Skills',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${profile.skills.length} skills',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.skills.map((skill) {
                    return SkillChip(skill: skill, isHighlighted: true);
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Areas of Interest Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Areas of Interest',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${profile.interests.length} topics',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondarySlate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.interests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.slateLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slateDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Academic Profile'),
          ),

          const SizedBox(height: 12),

          // Demo Reset Button (Judge Convenience)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondarySlate,
            ),
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Reset Demo Dataset',
                message:
                    'This will reset all profiles, requests, tasks, and teams to the initial competition evaluation seed state.',
                confirmText: 'Reset to Seed Data',
                isDestructive: true,
              );
              if (confirmed) {
                await LocalStore.resetToSeedData();
                ref.invalidate(profileProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dataset reset to competition demo state!'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Reset Competition Demo Data'),
          ),

          const SizedBox(height: 12),

          // Logout Action (Mandatory Feature)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.statusRejected,
              side: const BorderSide(color: AppColors.statusRejected, width: 1.2),
            ),
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Log Out',
                message:
                    'Are you sure you want to log out of TeamUp? Your local account and profile data will remain securely saved.',
                confirmText: 'Log Out',
                isDestructive: true,
              );
              if (confirmed) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log Out'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
