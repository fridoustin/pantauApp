import 'package:flutter/material.dart';
import 'package:pantau_app/common/widgets/navBar/navigation_bar_item.dart';
import 'package:pantau_app/core/constant/colors.dart';


class NavigationBarWidget extends StatelessWidget {
  final int? currentIndex;

  const NavigationBarWidget({super.key, this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor
      ),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      height: 76,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          NavigationBarItemWidget(
            index: 0, 
            iconAsset: 'assets/icons/home.svg', 
            label: "Home", 
            isSelected: currentIndex == 0,
            onTap: () => Navigator.of(context).pushReplacementNamed('/home')
          ),
          NavigationBarItemWidget(
            index: 1, 
            iconAsset: 'assets/icons/work.svg', 
            label: "Work", 
            isSelected: currentIndex == 1,
            onTap: () => Navigator.of(context).pushReplacementNamed('/work')
          ),
          NavigationBarItemWidget(
            index: 2, 
            iconAsset: 'assets/icons/calendar.svg', 
            label: "Calendar", 
            isSelected: currentIndex == 2,
            onTap: () => Navigator.of(context).pushReplacementNamed('/calendar')
          ),
          NavigationBarItemWidget(
            index: 3, 
            iconAsset: 'assets/icons/profile.svg', 
            label: "Profile", 
            isSelected: currentIndex == 3,
            onTap: () => Navigator.of(context).pushReplacementNamed('/profile')
          ),
        ],
      ),
    );
  }
}