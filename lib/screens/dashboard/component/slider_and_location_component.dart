import 'dart:async';

import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/screens/notification/notification_screen.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_data_model.dart';
import '../../../utils/common.dart';
import '../../service/search_service_screen.dart';

class SliderLocationComponent extends StatefulWidget {
  final List<SliderModel> sliderList;
  final List<ServiceData>? featuredList;
  final VoidCallback? callback;

  SliderLocationComponent({required this.sliderList, this.callback, this.featuredList});

  @override
  State<SliderLocationComponent> createState() => _SliderLocationComponentState();
}

const _fallbackSliderImages = [
  'assets/images/slider_car_wash_1.jpg',
  'assets/images/slider_car_wash_2.jpg',
  'assets/images/slider_car_wash_3.jpg',
  'assets/images/slider_car_wash_4.jpg',
];

class _SliderLocationComponentState extends State<SliderLocationComponent> {
  PageController sliderPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  bool _isDefaultImage(String url) {
    return url.isEmpty || url.contains('default.png') || url.contains('default.jpg');
  }

  int get _effectiveCount {
    final bool useLocal = widget.sliderList.isEmpty ||
        widget.sliderList.every((s) => _isDefaultImage(s.sliderImage.validate()));
    return useLocal ? _fallbackSliderImages.length : widget.sliderList.length;
  }

  @override
  void initState() {
    super.initState();
    if (getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true) && _effectiveCount >= 2) {
      _timer = Timer.periodic(Duration(seconds: DASHBOARD_AUTO_SLIDER_SECOND), (Timer timer) {
        if (_currentPage < _effectiveCount - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        sliderPageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 950), curve: Curves.easeOutQuart);
      });

      sliderPageController.addListener(() {
        _currentPage = sliderPageController.page!.toInt();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    sliderPageController.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return language.goodMorning;
    if (hour < 17) return language.goodAfternoon;
    return language.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;
    final bool useLocalFallback = widget.sliderList.isEmpty ||
        widget.sliderList.every((s) => _isDefaultImage(s.sliderImage.validate()));
    final int itemCount = useLocalFallback ? _fallbackSliderImages.length : widget.sliderList.length;

    return Column(
      children: [
        // Slider + Greeting overlay + Notification
        SizedBox(
          height: 280,
          width: context.width(),
          child: Stack(
            children: [
              // Slider images
              if (itemCount > 0)
                PageView(
                  controller: sliderPageController,
                  children: List.generate(itemCount, (index) {
                    if (useLocalFallback) {
                      return Image.asset(
                        _fallbackSliderImages[index],
                        height: 280,
                        width: context.width(),
                        fit: BoxFit.cover,
                      );
                    }
                    SliderModel data = widget.sliderList[index];
                    if (_isDefaultImage(data.sliderImage.validate())) {
                      return Image.asset(
                        _fallbackSliderImages[index % _fallbackSliderImages.length],
                        height: 280,
                        width: context.width(),
                        fit: BoxFit.cover,
                      ).onTap(() {
                        if (data.type == SERVICE) {
                          ServiceDetailScreen(serviceId: data.typeId.validate().toInt()).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                        }
                      });
                    }
                    return CachedImageWidget(url: data.sliderImage.validate(), height: 280, width: context.width(), fit: BoxFit.cover).onTap(() {
                      if (data.type == SERVICE) {
                        ServiceDetailScreen(serviceId: data.typeId.validate().toInt()).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                      }
                    });
                  }),
                )
              else
                CachedImageWidget(url: '', height: 280, width: context.width()),

              // Gradient overlay at bottom for greeting text
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Greeting text on slider
              Positioned(
                bottom: 16,
                left: 16,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()},',
                      style: primaryTextStyle(size: 14, color: Colors.white70),
                    ),
                    4.height,
                    Text(
                      appStore.isLoggedIn ? appStore.userFirstName : language.helloGuest,
                      style: boldTextStyle(size: 22, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Dot indicators
              if (itemCount > 1)
                Positioned(
                  bottom: 72,
                  left: 16,
                  child: Row(
                    children: List.generate(itemCount, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == index ? 18 : 6,
                        height: 4,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.white : Colors.white54,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),

              // Notification bell
              if (appStore.isLoggedIn)
                Positioned(
                  top: context.statusBarHeight + 12,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => NotificationScreen().launch(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications_outlined, color: Colors.white, size: 20).center(),
                          Observer(builder: (context) {
                            return Positioned(
                              top: -2,
                              right: -2,
                              child: appStore.unreadCount.validate() > 0
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: boxDecorationDefault(color: Colors.red, shape: BoxShape.circle),
                                      child: FittedBox(
                                        child: Text(appStore.unreadCount.toString(), style: primaryTextStyle(size: 10, color: Colors.white)),
                                      ),
                                    )
                                  : const Offstage(),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Location + Search bar
        Transform.translate(
          offset: const Offset(0, -24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Location button
                Expanded(
                  child: Observer(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () async {
                          locationWiseService(context, () {
                            widget.callback?.call();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? darkSurfaceVariant : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? darkBorderGlow.withValues(alpha: 0.4) : Colors.grey.shade200,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.location_on_outlined, size: 18, color: primaryColor),
                              ),
                              10.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Location',
                                      style: secondaryTextStyle(size: 10, color: isDark ? Colors.white38 : Colors.grey.shade500),
                                    ),
                                    2.height,
                                    Text(
                                      appStore.isCurrentLocation
                                          ? getStringAsync(CURRENT_ADDRESS)
                                          : language.lblLocationOff,
                                      style: boldTextStyle(size: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              6.width,
                              Icon(
                                appStore.isCurrentLocation ? Icons.my_location_rounded : Icons.location_disabled_rounded,
                                size: 18,
                                color: appStore.isCurrentLocation ? primaryColor : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                12.width,
                // Search button
                GestureDetector(
                  onTap: () {
                    SearchServiceScreen(featuredList: widget.featuredList).launch(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
