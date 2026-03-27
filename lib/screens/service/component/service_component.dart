import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceComponent extends StatefulWidget {
  final ServiceData serviceData;
  final double? width;
  final bool? isBorderEnabled;
  final VoidCallback? onUpdate;
  final bool isFavouriteService;
  final bool isFromDashboard;
  final bool isFromViewAllService;
  final bool isFromServiceDetail;
  final String bookingType;

  ServiceComponent({
    required this.serviceData,
    this.width,
    this.isBorderEnabled,
    this.isFavouriteService = false,
    this.onUpdate,
    this.isFromDashboard = false,
    this.isFromViewAllService = false,
    this.isFromServiceDetail = false,
    this.bookingType = "daily",
  });

  @override
  ServiceComponentState createState() => ServiceComponentState();
}

class ServiceComponentState extends State<ServiceComponent> {
  @override
  void initState() {
    super.initState();
  }

  String _getServiceImageUrl() {
    if (widget.isFavouriteService) {
      if (widget.serviceData.serviceAttachments.validate().isNotEmpty) {
        return widget.serviceData.serviceAttachments!.first.validate();
      }
    } else {
      if (widget.serviceData.attachments.validate().isNotEmpty) {
        return widget.serviceData.attachments!.first.validate();
      }
    }
    final catName = widget.serviceData.categoryName.validate().toLowerCase();
    if (catName.contains('car')) return car_image;
    if (catName.contains('bike')) return bike_image;
    if (catName.contains('scooty')) return scooty_image;
    if (catName.contains('bus') || catName.contains('van') || catName.contains('truck')) return bus_image;
    return car_image;
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
        ServiceDetailScreen(
          serviceId: widget.isFavouriteService
              ? widget.serviceData.serviceId.validate().toInt()
              : widget.serviceData.id.validate(),
          bookingType: widget.bookingType,
        ).launch(context).then((value) {
          setStatusBarColor(context.primaryColor);
          widget.onUpdate?.call();
        });
      },
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final bool isDark = appStore.isDarkMode;
    final data = widget.serviceData;
    final double cardWidth = widget.width ?? 280;
    final bool hasRating = data.totalRating.validate() > 0;
    final bool hasDescription = data.description.validate().isNotEmpty;
    final bool hasProvider = data.providerName.validate().isNotEmpty;
    final bool hasDuration = data.duration.validate().isNotEmpty && data.duration.validate() != '0';
    final String categoryLabel = data.subCategoryName.validate().isNotEmpty
        ? data.subCategoryName.validate()
        : data.categoryName.validate();

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? darkSurfaceVariant : Colors.white,
        border: Border.all(
          color: isDark ? darkBorderGlow.withValues(alpha: 0.5) : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: isDark
            ? [BoxShadow(color: primaryColor.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              height: 130,
              width: cardWidth,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImageWidget(
                    url: _getServiceImageUrl(),
                    fit: BoxFit.cover,
                    height: 130,
                    width: cardWidth,
                    circle: false,
                  ),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Category badge top-left
                  if (categoryLabel.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          categoryLabel,
                          style: boldTextStyle(color: Colors.white, size: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  // Favourite heart top-right
                  if (widget.isFavouriteService)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          if (data.isFavourite != 0) {
                            data.isFavourite = 1;
                            setState(() {});
                            await removeToWishList(serviceId: data.serviceId.validate().toInt()).then((value) {
                              if (!value) {
                                data.isFavourite = 1;
                                setState(() {});
                              }
                            });
                          } else {
                            data.isFavourite = 0;
                            setState(() {});
                            await addToWishList(serviceId: data.serviceId.validate().toInt()).then((value) {
                              if (!value) {
                                data.isFavourite = 1;
                                setState(() {});
                              }
                            });
                          }
                          widget.onUpdate?.call();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: data.isFavourite == 1
                              ? ic_fill_heart.iconImage(color: favouriteColor, size: 16)
                              : ic_heart.iconImage(color: unFavouriteColor, size: 16),
                        ),
                      ),
                    ),
                  // Online indicator
                  if (data.isOnlineService)
                    Positioned(
                      top: 8,
                      right: widget.isFavouriteService ? 40 : 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Online', style: boldTextStyle(size: 9, color: Colors.white)),
                      ),
                    ),
                  // Service name on image bottom
                  Positioned(
                    bottom: 8,
                    left: 10,
                    right: 10,
                    child: Text(
                      data.name.validate(),
                      style: boldTextStyle(size: 14, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (hasDescription)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      data.description.validate(),
                      style: secondaryTextStyle(size: 12, color: isDark ? Colors.white54 : Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Info chips row: duration + rating
                Row(
                  children: [
                    if (hasDuration) ...[
                      Icon(Icons.schedule_rounded, size: 13, color: isDark ? Colors.white54 : Colors.grey.shade500),
                      4.width,
                      Text(
                        '${data.duration} min',
                        style: secondaryTextStyle(size: 11, color: isDark ? Colors.white54 : Colors.grey.shade600),
                      ),
                      if (hasRating) ...[
                        Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white30 : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                    if (hasRating) ...[
                      Icon(Icons.star_rounded, size: 14, color: ratingBarColor),
                      3.width,
                      Text(
                        data.totalRating.validate().toStringAsFixed(1),
                        style: boldTextStyle(size: 12, color: isDark ? Colors.white70 : Colors.grey.shade700),
                      ),
                      if (data.totalReview.validate() > 0) ...[
                        3.width,
                        Text(
                          '(${data.totalReview.validate().toInt()})',
                          style: secondaryTextStyle(size: 10, color: isDark ? Colors.white38 : Colors.grey.shade500),
                        ),
                      ],
                    ],
                    if (!hasRating && !hasDuration)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NEW',
                          style: boldTextStyle(size: 10, color: const Color(0xFF10B981)),
                        ),
                      ),
                  ],
                ),
                10.height,

                // Price + Provider row
                Row(
                  children: [
                    // Price
                    if (data.effectivePrice > 0) ...[
                      Expanded(
                        child: Row(
                          children: [
                            if (data.price.validate() == 0 && data.minPlanPrice != null)
                              Text("From ", style: secondaryTextStyle(size: 10, color: isDark ? Colors.white38 : Colors.grey.shade500)),
                            PriceWidget(
                              price: data.effectivePrice,
                              isHourlyService: data.isHourlyService,
                              color: primaryColor,
                              hourlyTextColor: primaryColor,
                              size: 15,
                              isFreeService: data.isFreeService,
                            ),
                            if (data.discount.validate() > 0) ...[
                              6.width,
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${data.discount.validate().toInt()}% off',
                                  style: boldTextStyle(size: 10, color: Colors.red),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Text(
                          data.isFreeService ? language.lblFree : '',
                          style: boldTextStyle(size: 14, color: const Color(0xFF10B981)),
                        ),
                      ),
                    ],
                    // Provider avatar
                    if (hasProvider)
                      GestureDetector(
                        onTap: () async {
                          if (data.providerId != appStore.userId.validate()) {
                            await ProviderInfoScreen(providerId: data.providerId.validate()).launch(context);
                            setStatusBarColor(Colors.transparent);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ImageBorder(src: data.providerImage.validate(), height: 22),
                            6.width,
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 80),
                              child: Text(
                                data.providerName.validate(),
                                style: secondaryTextStyle(size: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
