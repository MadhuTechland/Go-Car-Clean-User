import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/service/instant_wash.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class QuickActionComponent extends StatelessWidget {
  const QuickActionComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              title: 'Instant Wash',
              imagePath: 'assets/images/instant.png',
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstantWashScreen()),
                );
              },
            ),
          ),
          16.width,
          Expanded(
            child: _QuickActionCard(
              title: 'Daily Wash',
              imagePath: 'assets/images/daily.png',
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstantWashScreen(bookingType: "daily")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.imagePath,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? quickActionCardBg : context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? quickActionCardBorder : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                imagePath,
                height: 36,
                width: 36,
                fit: BoxFit.contain,
              ),
            ),
            10.height,
            Text(
              title,
              style: boldTextStyle(
                size: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
