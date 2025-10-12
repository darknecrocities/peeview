import 'package:flutter/material.dart';
import 'package:peeview/widgets/customize_back_button.dart';
import 'package:peeview/widgets/customize_skip_button.dart';

class CustomizeNavAuth extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double height;
  final bool showBackButton;
  final bool showSkipButton;
  final bool showTitle;
  final Widget? nextScreen;

  const CustomizeNavAuth({
    super.key,
    this.height = 80,
    required this.showBackButton,
    required this.showSkipButton,
    required this.showTitle,
    this.nextScreen,
    this.title,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: true,
      leading: showBackButton
          ? const Padding(
        padding: EdgeInsets.only(left: 18),
        child: Align(
          alignment: Alignment.centerLeft,
          child: CustomizeBackButton(),
        ),
      )
          : const SizedBox(width: 48),
      title: showTitle && title != null
          ? Text(
        title!,
        style: const TextStyle(
          color: Color(0XFF0062C8),
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      )
          : const SizedBox(),
      actions: [
        showSkipButton && nextScreen != null
            ? Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: CustomizeSkipButton(nextScreen: nextScreen!),
        )
            : const SizedBox(width: 48),
      ],
    );
  }
}
