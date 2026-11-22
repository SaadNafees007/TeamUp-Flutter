import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../providers/profile_provider.dart';

class AvatarPickerModal extends ConsumerWidget {
  const AvatarPickerModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AvatarPickerModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAvatar = ref.watch(profileProvider).profile.avatar;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slateLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Select Profile Avatar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose from styled preset avatars or select a photo from your gallery.',
            style: TextStyle(fontSize: 13, color: AppColors.secondarySlate),
          ),
          const SizedBox(height: 20),

          // Option A: Gallery Image Picker (FR-1.4 Bonus)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _pickFromGallery(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigoLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryIndigo,
                    size: 24,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload from Gallery',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryIndigoDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Select custom photo from device storage',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryIndigo,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'Preset Designer Avatars',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Option B: Preset Avatars Grid (FR-1.4 Bonus)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppConstants.presetAvatars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final presetKey = AppConstants.presetAvatars[index];
              final isSelected = currentAvatar == presetKey;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ref.read(profileProvider.notifier).updateAvatar(presetKey);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.slateLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryIndigo
                          : AppColors.border,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: AvatarWidget(
                      avatarKey: presetKey,
                      name: 'Student',
                      radius: 28,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  ),
);
  }

  Future<void> _pickFromGallery(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await ref.read(profileProvider.notifier).updateAvatar(pickedFile.path);
        if (context.mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      // Graceful fallback to presets if gallery denied or fails
      debugPrint('[AvatarPicker] Gallery access error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gallery unavailable. Please pick a preset avatar.'),
          ),
        );
      }
    }
  }
}
