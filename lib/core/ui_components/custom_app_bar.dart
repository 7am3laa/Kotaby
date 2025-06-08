import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/core/ui_components/custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;
  final bool islead;
  final bool iscenterTitle;
  final bool issearch;
  final Function? onChanged;
  final VoidCallback? onColse;
  final bool isBlack;
  final TextEditingController? searchController;
  final PreferredSizeWidget? bottom;
  final bool isDrawer;
  final String fontFamily;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor = primaryColor,
    this.textColor,
    this.islead = true,
    this.iscenterTitle = true,
    this.issearch = false,
    this.onChanged,
    this.onColse,
    this.isBlack = false,
    this.searchController,
    this.bottom,
    this.isDrawer = false,
    this.fontFamily = "Hafs",
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: iscenterTitle,
      iconTheme: IconThemeData(color: Colors.white),
      title: CustomText(
        text: title,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: fontFamily,
        fontSize: (width > 500 && width < 750)
            ? 17
            : width >= 750
                ? 10
                : 20,
      ),
      leading: islead
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios_new_outlined,
                  color: isBlack ? Colors.black : Colors.white),
            )
          : isDrawer
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      issearch ? 130.w : (bottom != null ? 90 : kToolbarHeight));
}
