import 'package:flutter/material.dart';
import 'package:pantau_app/common/widgets/navBar/navigation_bar.dart';
import 'package:pantau_app/core/constant/colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Jika bukan di index ke-0 (Home), arahkan ke Home
        if (currentIndex != 0) {
          Navigator.pushReplacementNamed(context, '/home');
          return false;
        }

        // Sudah di Home, izinkan keluar
        return true;
      },
      child: Scaffold(
        appBar: appBar,
        body: child,
        bottomNavigationBar: NavigationBarWidget(currentIndex: currentIndex),
        floatingActionButton: floatingActionButton,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => Navigator.pushNamed(context, '/createworkorder'),
        // ),
        backgroundColor: AppColors.backgroundColor,
      ),
    );
  }
}
