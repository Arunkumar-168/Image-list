import 'package:flutter/material.dart';
import 'package:flutter_application_6/component/paymentListTile.dart';
import 'package:flutter_application_6/config/size_config.dart';
import 'package:flutter_application_6/data.dart';
import 'package:flutter_application_6/style/colors.dart';
import 'package:flutter_application_6/style/style.dart';

class PaymentDetailList extends StatelessWidget {
  const PaymentDetailList({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: SizeConfig.blockSizeVertical * 5,
      ),
      Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: [
          BoxShadow(
            color: Colors.red,
            blurRadius: 15.0,
            offset: const Offset(
              10.0,
              15.0,
            ),
          )
        ]),
        child: Image.asset('assets/card.png'),
      ),
      SizedBox(
        height: SizeConfig.blockSizeVertical * 5,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryText(
              text: 'Recent Activities', size: 18, fontWeight: FontWeight.w800),
          PrimaryText(
            text: '02 Mar 2021',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.secondary,
          ),
        ],
      ),
      SizedBox(
        height: SizeConfig.blockSizeVertical * 2,
      ),
      Column(
        children: List.generate(
          recentActivities.length,
              (index) => PaymentListTile(
            icon: recentActivities[index]["icon"] ?? 'assets/default_icon.svg', // Provide a default icon
            label: recentActivities[index]["label"] ?? 'Unknown Label', // Provide a default label
            amount: recentActivities[index]["amount"] ?? '\$0', // Provide a default amount
          ),
        ),
      ),
      SizedBox(
        height: SizeConfig.blockSizeVertical * 5,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryText(
              text: 'Upcoming Payments', size: 18, fontWeight: FontWeight.w800),
          PrimaryText(
            text: '02 Mar 2021',
            size: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.secondary,
          ),
        ],
      ),
      SizedBox(
        height: SizeConfig.blockSizeVertical * 2,
      ),
      Column(
        children: List.generate(
          upcomingPayments.length,
          (index) => PaymentListTile(
              icon: upcomingPayments[index]["icon"] ?? 'assets/default_icon.svg',
              label: upcomingPayments[index]["label"] ?? 'Unknown Label',
              amount: upcomingPayments[index]["amount"] ?? '\$0',
        ),
      ),),
    ]
    );
  }
}
