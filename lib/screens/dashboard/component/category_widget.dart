import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../newDashboard/dashboard_3/component/category_dashboard_component_3.dart';
import '../../newDashboard/dashboard_4/component/category_dashboard_component_4.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryData categoryData;
  final double? width;
  final bool? isFromCategory;

  CategoryWidget({required this.categoryData, this.width, this.isFromCategory});

  // Map category names to accent colors for visual distinction
  Color _getCategoryAccentColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('car')) return Color(0xFF1B3A5C);
    if (lower.contains('bike')) return Color(0xFFEC4899);
    if (lower.contains('scooty') || lower.contains('scooter')) return Color(0xFF10B981);
    if (lower.contains('bus') || lower.contains('van') || lower.contains('truck')) return Color(0xFFF59E0B);
    return primaryColor;
  }

  Widget buildDefaultComponent(BuildContext context) {
    final bool isDark = appStore.isDarkMode;
    final Color accentColor = _getCategoryAccentColor(categoryData.name.validate());
    final bool isSvg = categoryData.categoryImage.validate().endsWith('.svg');

    return Container(
      width: width ?? 90,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? accentColor.withValues(alpha: 0.3) : accentColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: isDark
            ? [BoxShadow(color: accentColor.withValues(alpha: 0.08), blurRadius: 12)]
            : [BoxShadow(color: accentColor.withValues(alpha: 0.08), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: isSvg
                ? SvgPicture.network(
                    categoryData.categoryImage.validate(),
                    height: 26,
                    width: 26,
                    colorFilter: ColorFilter.mode(isDark ? Colors.white : accentColor, BlendMode.srcIn),
                    placeholderBuilder: (context) => PlaceHolderWidget(
                      height: 26,
                      width: 26,
                      color: transparentColor,
                    ),
                  ).center()
                : CachedImageWidget(
                    url: categoryData.categoryImage.validate(),
                    fit: BoxFit.contain,
                    width: 28,
                    height: 28,
                    circle: false,
                    placeHolderImage: '',
                  ).center(),
          ),
          8.height,
          Text(
            categoryData.name.validate(),
            style: boldTextStyle(size: 12, color: isDark ? Colors.white : Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget categoryComponent() {
      return Observer(builder: (context) {
        if (appConfigurationStore.userDashboardType == DASHBOARD_1) {
          return buildDefaultComponent(context);
        } else if (appConfigurationStore.userDashboardType == DASHBOARD_2) {
          return buildDefaultComponent(context);
        } else if (appConfigurationStore.userDashboardType == DASHBOARD_3) {
          return CategoryDashboardComponent3(categoryData: categoryData, width: context.width() / 4 - 20);
        } else if (appConfigurationStore.userDashboardType == DASHBOARD_4) {
          return CategoryDashboardComponent4(categoryData: categoryData);
        } else {
          return buildDefaultComponent(context);
        }
      });
    }

    return categoryComponent();
  }
}
