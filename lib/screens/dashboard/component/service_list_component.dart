import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../service/view_all_service_screen.dart';

class ServiceListComponent extends StatelessWidget {
  final List<ServiceData> serviceList;

  ServiceListComponent({required this.serviceList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nearby Services', style: boldTextStyle(size: 16)),
                  4.height,
                  Text(
                    'Services available near you',
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
              ).expand(),
              if (serviceList.length >= 4)
                TextButton(
                  onPressed: () => ViewAllServiceScreen().launch(context),
                  child: Text(language.lblViewAll, style: boldTextStyle(size: 12, color: primaryColor)),
                ),
            ],
          ),
        ),
        8.height,
        serviceList.isNotEmpty
            ? HorizontalList(
                itemCount: serviceList.length,
                spacing: 16,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, index) => ServiceComponent(
                  serviceData: serviceList[index],
                  width: 260,
                  isBorderEnabled: true,
                  bookingType: "daily",
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: NoDataWidget(
                  title: language.lblNoServicesFound,
                  imageWidget: EmptyStateWidget(),
                ),
              ).center(),
      ],
    );
  }
}
