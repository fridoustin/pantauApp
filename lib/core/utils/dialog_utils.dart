import 'package:flutter/material.dart';
import 'package:pantau_app/core/constant/colors.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String contentText,
  required IconData iconData,
  double width = 300,
  double height = 200,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardColor,
        icon: Icon(
          iconData,
          color: Colors.red,
          size: 100,
        ),
        content: Text(
          contentText,
          style: const TextStyle(
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Okay"),
          ),
        ],
      );
    },
  );
}