import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../component/cached_image_widget.dart';
import '../../../../model/dashboard_model.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/constant.dart';
import '../../../service/service_detail_screen.dart';

class SliderDashboardComponent2 extends StatefulWidget {
  final List<SliderModel> sliderList;

  SliderDashboardComponent2({required this.sliderList});

  @override
  _SliderDashboardComponent2State createState() => _SliderDashboardComponent2State();
}

const _fallbackSliderImages = [
  'assets/images/slider_car_wash_1.jpg',
  'assets/images/slider_car_wash_2.jpg',
  'assets/images/slider_car_wash_3.jpg',
  'assets/images/slider_car_wash_4.jpg',
];

class _SliderDashboardComponent2State extends State<SliderDashboardComponent2> {
  int _currentPage = 0;

  bool _isDefaultImage(String url) {
    return url.isEmpty || url.contains('default.png') || url.contains('default.jpg');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool useLocalFallback = widget.sliderList.isEmpty ||
        widget.sliderList.every((s) => _isDefaultImage(s.sliderImage.validate()));
    final int itemCount = useLocalFallback ? _fallbackSliderImages.length : widget.sliderList.length;

    return Column(
      children: [
        itemCount > 0
            ? CarouselSlider(
                items: List.generate(itemCount, (index) {
                  if (useLocalFallback || _isDefaultImage(widget.sliderList[index].sliderImage.validate())) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        _fallbackSliderImages[index % _fallbackSliderImages.length],
                        height: 200,
                        width: context.width(),
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  SliderModel data = widget.sliderList[index];
                  return CachedImageWidget(
                    url: data.sliderImage.validate(),
                    height: 200,
                    width: context.width(),
                    radius: 8,
                    fit: BoxFit.cover,
                  ).onTap(() {
                    if (data.type == SERVICE) {
                      ServiceDetailScreen(serviceId: data.typeId.validate().toInt()).launch(
                        context,
                        pageRouteAnimation: PageRouteAnimation.Fade,
                      );
                    }
                  });
                }),
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
              )
            : CachedImageWidget(url: '', height: 200, width: context.width()),
        if (itemCount > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              itemCount,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 0),
                height: 4,
                width: 30,
                decoration: BoxDecoration(
                  color: _currentPage == index ? primaryColor : context.cardColor,
                  borderRadius: index == 0
                      ? BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          topRight: Radius.circular(_currentPage == index ? 5 : 0),
                          bottomRight: Radius.circular(_currentPage == index ? 5 : 0),
                        )
                      : itemCount - 1 == index
                          ? BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                              bottomLeft: Radius.circular(_currentPage == index ? 5 : 0),
                              topLeft: Radius.circular(_currentPage == index ? 5 : 0),
                            )
                          : BorderRadius.circular(_currentPage == index ? 5 : 0),
                ),
              ),
            ),
          ).paddingTop(16),
      ],
    );
  }
}
