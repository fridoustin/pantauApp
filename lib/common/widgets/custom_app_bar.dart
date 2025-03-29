import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushReplacementNamed('/profile'),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/default_avatar.png'),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/notification'), 
              child: SvgPicture.asset(
                'assets/icons/notification.svg',
              ),
            ),
          ],
        ),
      ),
    );
  }
}