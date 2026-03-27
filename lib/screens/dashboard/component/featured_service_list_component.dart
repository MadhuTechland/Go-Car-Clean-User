import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../service/view_all_service_screen.dart';

class FeaturedServiceListComponent extends StatelessWidget {
  final List<ServiceData> serviceList;

  FeaturedServiceListComponent({required this.serviceList});

  @override
  Widget build(BuildContext context) {
    if (serviceList.isEmpty) return Offstage();

    final bool isDark = appStore.isDarkMode;

    return Container(
      padding: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [darkSurfaceVariant, scaffoldColorDark],
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryColor.withValues(alpha: 0.06), primaryColor.withValues(alpha: 0.02)],
              ),
        border: isDark
            ? Border(top: BorderSide(color: darkBorderGlow.withValues(alpha: 0.3), width: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                    8.width,
                    Text('Featured', style: boldTextStyle(size: 16)),
                  ],
                ).expand(),
                if (serviceList.length >= 4)
                  TextButton(
                    onPressed: () => ViewAllServiceScreen(isFeatured: "1").launch(context),
                    child: Text(language.lblViewAll, style: boldTextStyle(size: 12, color: primaryColor)),
                  ),
              ],
            ),
          ),
          4.height,
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              'Top rated and recommended services',
              style: secondaryTextStyle(size: 12),
            ),
          ),
          8.height,
          if (serviceList.isNotEmpty)
            HorizontalList(
              itemCount: serviceList.length,
              spacing: 16,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) => ServiceComponent(
                serviceData: serviceList[index],
                width: 260,
                isBorderEnabled: true,
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: NoDataWidget(
                title: language.lblNoServicesFound,
                imageWidget: EmptyStateWidget(),
              ),
            ).center(),
        ],
      ),
    );
  }
}
