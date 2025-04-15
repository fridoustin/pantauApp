import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileOption extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            // ignore: deprecated_member_use
            SvgPicture.asset(icon, width: 24, height: 24, color: const Color(0xFF000000),),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}