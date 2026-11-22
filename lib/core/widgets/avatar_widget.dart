import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarKey;
  final String name;
  final double radius;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.avatarKey,
    required this.name,
    this.radius = 24,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a local file path
    final isCustomFile =
        avatarKey.startsWith('/') ||
        avatarKey.contains(':\\') ||
        avatarKey.contains(':/');

    if (isCustomFile) {
      final file = File(avatarKey);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.slateLight,
          backgroundImage: FileImage(file),
        );
      }
    }

    // Preset avatars: generate attractive gradients and distinctive icons
    final presetDetails = _getPresetDetails(avatarKey, name);

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: presetDetails.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: showBorder ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: presetDetails.gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: presetDetails.icon != null
            ? Icon(presetDetails.icon, color: Colors.white, size: radius * 1.05)
            : Text(
                _getInitials(name),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: radius * 0.75,
                  letterSpacing: -0.5,
                ),
              ),
      ),
    );
  }

  String _getInitials(String input) {
    final parts = input.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'TU';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  _PresetInfo _getPresetDetails(String key, String fallbackName) {
    switch (key) {
      case 'avatar_1':
        return _PresetInfo(
          gradientColors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          icon: Icons.code_rounded,
        );
      case 'avatar_2':
        return _PresetInfo(
          gradientColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
          icon: Icons.terminal_rounded,
        );
      case 'avatar_3':
        return _PresetInfo(
          gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
          icon: Icons.psychology_rounded,
        );
      case 'avatar_4':
        return _PresetInfo(
          gradientColors: const [Color(0xFFD97706), Color(0xFFF59E0B)],
          icon: Icons.cloud_done_rounded,
        );
      case 'avatar_5':
        return _PresetInfo(
          gradientColors: const [Color(0xFFDB2777), Color(0xFFF43F5E)],
          icon: Icons.palette_rounded,
        );
      case 'avatar_6':
        return _PresetInfo(
          gradientColors: const [Color(0xFF7C3AED), Color(0xFF9333EA)],
          icon: Icons.security_rounded,
        );
      default:
        return _PresetInfo(
          gradientColors: const [Color(0xFF4F46E5), Color(0xFF6366F1)],
          icon: null,
        );
    }
  }
}

class _PresetInfo {
  final List<Color> gradientColors;
  final IconData? icon;

  _PresetInfo({required this.gradientColors, this.icon});
}
