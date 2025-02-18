import 'package:flutter/material.dart';
import 'package:flutter_application_6/config/responsive.dart';
import 'package:flutter_application_6/style/colors.dart';
import 'package:flutter_application_6/style/style.dart';

class Header extends StatelessWidget {
  const Header({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      SizedBox(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryText(
                  text: 'Dashboard',
                  size: 30,
                  fontWeight: FontWeight.w800),
              PrimaryText(
                text: 'Payments updates',
                size: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.secondary,
              )
            ]),
      ),
      Spacer(
        flex: 1,
      ),
      Expanded(
        flex: Responsive.isDesktop(context) ? 1 : 3,
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                EdgeInsets.only(left: 40.0, right: 5),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.white),
            ),
             focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.white),
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.black),
            hintText: 'Search',
            hintStyle: TextStyle(color: AppColors.secondary, fontSize: 14)
          ),
        ),
      ),
    ]);
  }
}
