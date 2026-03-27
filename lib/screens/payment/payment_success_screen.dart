import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int bookingId;
  final num totalAmountPaid;
  final bool isAdvancePayment;

  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.totalAmountPaid,
    this.isAdvancePayment = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Success icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.primaryColor,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),

                Text(
                  'Payment Successful!',
                  style: boldTextStyle(size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  isAdvancePayment
                      ? 'Your advance payment has been received.'
                      : 'Your payment has been received.',
                  style: secondaryTextStyle(size: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Amount card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: appStore.isDarkMode
                        ? Border.all(color: darkBorderGlow.withOpacity(0.3))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        isAdvancePayment ? 'Advance Paid' : 'Amount Paid',
                        style: secondaryTextStyle(size: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        totalAmountPaid.toPriceFormat(),
                        style: boldTextStyle(size: 28, color: primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Booking ID: ', style: secondaryTextStyle()),
                          Text('#$bookingId', style: boldTextStyle(size: 14)),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Buttons
                AppButton(
                  width: context.width(),
                  text: 'View Booking',
                  textStyle: boldTextStyle(color: Colors.white),
                  color: context.primaryColor,
                  onTap: () {
                    DashboardScreen(redirectToBooking: true).launch(
                      context,
                      isNewTask: true,
                      pageRouteAnimation: PageRouteAnimation.Fade,
                    );
                    BookingDetailScreen(bookingId: bookingId).launch(context);
                  },
                ),
                const SizedBox(height: 12),
                AppButton(
                  width: context.width(),
                  text: language.goToHome,
                  textStyle: boldTextStyle(size: 14),
                  shapeBorder: RoundedRectangleBorder(
                    borderRadius: radius(),
                    side: BorderSide(color: primaryColor),
                  ),
                  color: context.scaffoldBackgroundColor,
                  onTap: () {
                    DashboardScreen().launch(context, isNewTask: true);
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
