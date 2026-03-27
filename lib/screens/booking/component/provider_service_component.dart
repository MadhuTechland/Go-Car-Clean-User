import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/price_widget.dart';
import '../../../main.dart';
import '../../../model/package_data_model.dart';
import '../../../model/service_data_model.dart';
import '../../../utils/colors.dart';
import '../../../utils/common.dart';
import '../../../utils/images.dart';
import '../../service/service_detail_screen.dart';

class ProviderServiceComponent extends StatefulWidget {
  final ServiceData? serviceData;
  final BookingPackage? selectedPackage;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final bool isFavouriteService;
  final bool isFromProviderInfo;

  ProviderServiceComponent({
    this.serviceData,
    this.selectedPackage,
    this.isBorderEnabled,
    this.onUpdate,
    this.isFavouriteService = false,
    this.isFromProviderInfo = false,
  });

  @override
  _ProviderServiceComponentState createState() => _ProviderServiceComponentState();
}

class _ProviderServiceComponentState extends State<ProviderServiceComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  String _getServiceImageUrl() {
    // Try service-specific attachments first
    if (widget.isFavouriteService) {
      if (widget.serviceData!.serviceAttachments.validate().isNotEmpty) {
        return widget.serviceData!.serviceAttachments!.first.validate();
      }
    } else {
      if (widget.serviceData!.attachments.validate().isNotEmpty) {
        return widget.serviceData!.attachments!.first.validate();
      }
    }
    // Fallback to category-based vehicle image
    final catName = widget.serviceData!.categoryName.validate().toLowerCase();
    if (catName.contains('car')) return car_image;
    if (catName.contains('bike')) return bike_image;
    if (catName.contains('scooty')) return scooty_image;
    if (catName.contains('bus') || catName.contains('van') || catName.contains('truck')) return bus_image;
    return car_image; // default fallback
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        ServiceDetailScreen(serviceId: widget.isFavouriteService ? widget.serviceData!.serviceId.validate().toInt() : widget.serviceData!.id.validate()).launch(context).then((value) {
          setStatusBarColor(context.primaryColor);
        });
      },
      child: Container(
        width: context.width(),
        padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
          border: widget.isBorderEnabled.validate(value: false)
              ? appStore.isDarkMode
                  ? Border.all(color: context.dividerColor)
                  : null
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImageWidget(
              url: _getServiceImageUrl(),
              fit: BoxFit.cover,
              height: 85,
              width: 85,
              circle: false,
              radius: defaultRadius,
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: appStore.isDarkMode ? Colors.black : lightPrimaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Text(
                          widget.serviceData!.categoryName.validate(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).flexible(),
                      TextIcon(
                        suffix: Row(
                          children: [
                            Image.asset(ic_star_fill, height: 12, color: getRatingBarColor(widget.serviceData!.totalRating.validate().toInt())),
                            4.width,
                            Text("${widget.serviceData!.totalRating.validate().toStringAsFixed(1)}", style: boldTextStyle()),
                          ],
                        ),
                      ),
                    ],
                  ),
                  10.height,
                  Text(
                    widget.serviceData!.name.validate(),
                    style: primaryTextStyle(weight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  10.height,
                  if (widget.serviceData!.effectivePrice > 0)
                    Row(
                      children: [
                        if (widget.serviceData!.price.validate() == 0 && widget.serviceData!.minPlanPrice != null)
                          Text("From ", style: secondaryTextStyle(size: 12)),
                        PriceWidget(
                          size: 14,
                          price: widget.serviceData!.effectivePrice,
                          color: primaryColor,
                        ),
                        if (widget.serviceData!.discount.validate() > 0) ...[
                          8.width,
                          PriceWidget(
                            size: 12,
                            price: widget.serviceData!.price.validate(),
                            isDiscountedPrice: true,
                            color: textSecondaryColorGlobal,
                            isLineThroughEnabled: true,
                          ),
                          10.width,
                          Text(
                            "${widget.serviceData!.discount.validate()}% off",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: defaultActivityStatus, fontWeight: FontWeight.bold, fontSize: 12),
                          ).expand(),
                        ],
                      ],
                    )
                  else
                    Text("View Plans", style: primaryTextStyle(size: 12, color: primaryColor)),
                ],
              ),
            ),
            8.width,
            if (widget.isFavouriteService)
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: context.cardColor),
                child: widget.serviceData!.isFavourite == 0 ? ic_fill_heart.iconImage(color: favouriteColor, size: 18) : ic_heart.iconImage(color: unFavouriteColor, size: 18),
              ).onTap(() async {
                if (widget.serviceData!.isFavourite == 0) {
                  widget.serviceData!.isFavourite = 1;
                  setState(() {});

                  await removeToWishList(serviceId: widget.serviceData!.serviceId.validate().toInt()).then((value) {
                    if (!value) {
                      widget.serviceData!.isFavourite = 0;
                      setState(() {});
                    }
                  });
                } else {
                  widget.serviceData!.isFavourite = 0;
                  setState(() {});

                  await addToWishList(serviceId: widget.serviceData!.serviceId.validate().toInt()).then((value) {
                    if (!value) {
                      widget.serviceData!.isFavourite = 1;
                      setState(() {});
                    }
                  });
                }
                widget.onUpdate?.call();
              }),
          ],
        ),
      ),
    );
  }
}
