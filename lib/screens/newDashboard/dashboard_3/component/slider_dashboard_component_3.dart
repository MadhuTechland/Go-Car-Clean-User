import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../component/cached_image_widget.dart';
import '../../../../model/dashboard_model.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/configs.dart';
import '../../../../utils/constant.dart';
import '../../../service/service_detail_screen.dart';

class SliderDashboardComponent3 extends StatefulWidget {
  final List<SliderModel> sliderList;

  SliderDashboardComponent3({required this.sliderList});

  @override
  _SliderDashboardComponent3State createState() => _SliderDashboardComponent3State();
}

const _fallbackSliderImages = [
  'assets/images/slider_car_wash_1.jpg',
  'assets/images/slider_car_wash_2.jpg',
  'assets/images/slider_car_wash_3.jpg',
  'assets/images/slider_car_wash_4.jpg',
];

class _SliderDashboardComponent3State extends State<SliderDashboardComponent3> {
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
    init();
  }

  void init() async {
    if (getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true) && _effectiveCount >= 2) {
      _timer = Timer.periodic(Duration(seconds: DASHBOARD_AUTO_SLIDER_SECOND), (Timer timer) {
        if (_currentPage < _effectiveCount - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        sliderPageController.animateToPage(_currentPage, duration: Duration(milliseconds: 950), curve: Curves.easeOutQuart);
      });

      sliderPageController.addListener(() {
        _currentPage = sliderPageController.page!.toInt();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    sliderPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool useLocalFallback = widget.sliderList.isEmpty ||
        widget.sliderList.every((s) => _isDefaultImage(s.sliderImage.validate()));
    final int itemCount = useLocalFallback ? _fallbackSliderImages.length : widget.sliderList.length;

    return SizedBox(
      height: 190,
      width: context.width(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          itemCount > 0
              ? PageView(
                  controller: sliderPageController,
                  physics: ClampingScrollPhysics(),
                  children: List.generate(
                    itemCount,
                    (index) {
                      if (useLocalFallback || _isDefaultImage(widget.sliderList[index].sliderImage.validate())) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _fallbackSliderImages[index % _fallbackSliderImages.length],
                            height: 190,
                            width: context.width() - 32,
                            fit: BoxFit.cover,
                          ),
                        ).paddingSymmetric(horizontal: 16);
                      }
                      SliderModel data = widget.sliderList[index];
                      return CachedImageWidget(
                        url: data.sliderImage.validate(),
                        height: 190,
                        width: context.width() - 32,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(8).onTap(() {
                        if (data.type == SERVICE) {
                          ServiceDetailScreen(serviceId: data.typeId.validate().toInt()).launch(
                            context,
                            pageRouteAnimation: PageRouteAnimation.Fade,
                          ).then((value) {
                            setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.dark, delayInMilliSeconds: 1000);
                          });
                        }
                      }).paddingSymmetric(horizontal: 16);
                    },
                  ),
                )
              : CachedImageWidget(url: '', height: 175, width: context.width()),
          if (itemCount > 1)
            Positioned(
              bottom: -25,
              left: 0,
              right: 0,
              child: DotIndicator(
                pageController: sliderPageController,
                pages: List.generate(itemCount, (_) => _),
                indicatorColor: primaryColor,
                unselectedIndicatorColor: primaryLightColor,
                currentBoxShape: BoxShape.rectangle,
                boxShape: BoxShape.rectangle,
                borderRadius: radius(2),
                currentBorderRadius: radius(3),
                currentDotSize: 18,
                currentDotWidth: 6,
                dotSize: 6,
              ),
            ),
        ],
      ),
    );
  }
}
