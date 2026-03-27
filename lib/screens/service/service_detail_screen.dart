import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/online_service_icon_widget.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/model/slot_data.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/book_service_screen.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_provider_widget.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_component_instance.dart';
import 'package:booking_system_flutter/screens/review/components/review_widget.dart';
import 'package:booking_system_flutter/screens/review/rating_view_all_screen.dart';
import 'package:booking_system_flutter/screens/service/component/all_plans_screen.dart';
import 'package:booking_system_flutter/screens/service/component/related_service_component.dart';
import 'package:booking_system_flutter/screens/service/component/service_detail_header_component.dart';
import 'package:booking_system_flutter/screens/service/component/service_faq_widget.dart';
import 'package:booking_system_flutter/screens/service/component/vehicle_selector_bottomsheet.dart';
import 'package:booking_system_flutter/screens/service/instant_wash.dart';
import 'package:booking_system_flutter/screens/service/package/package_component.dart';
import 'package:booking_system_flutter/screens/service/service_book.dart';
import 'package:booking_system_flutter/screens/service/shimmer/service_detail_shimmer.dart';
import 'package:booking_system_flutter/store/service_addon_store.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/images.dart';
import 'addons/service_addons_component.dart';

ServiceAddonStore serviceAddonStore = ServiceAddonStore();

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  final ServiceData? service;
  final bool isFromProviderInfo;
  final String bookingType;
  ServiceDetailScreen({
    required this.serviceId,
    this.service,
    this.isFromProviderInfo = false,
    this.bookingType = "daily",
  });

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with TickerProviderStateMixin {
  PageController pageController = PageController();

  Future<ServiceDetailResponse>? future;
  int? selectedPlanId;
  double? selectedPlanPrice;
  int selectedAddressId = 0;
  int selectedBookingAddressId = -1;
  BookingPackage? selectedPackage;
  int selectedWashWhere = 0;
  CategoryData? selectedCategory;
  List<SelectedVehiclePlan> selectedPlans = [];
  Future<List<CategoryData>>? futureSubcategories;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    serviceAddonStore.selectedServiceAddon.clear();
    setStatusBarColor(transparentColor);

    // Pre-fill personal details from logged-in user
    if (appStore.isLoggedIn) {
      nameCtrl.text = appStore.userFullName;
      String phone = appStore.userContactNumber;
      if (phone.contains('-')) phone = phone.split('-').last;
      phoneCtrl.text = phone;
    }

    init();
  }

  void init() async {
    future = getServiceDetails(
        serviceId: widget.serviceId.validate(), customerId: appStore.userId);
  }

  void loadSubcategories(int catId) {
    futureSubcategories = getSubCategoryListAPI(catId: catId);
    setState(() {});
  }

  //region Widgets
  Widget availableWidget({required ServiceData data}) {
    if (data.serviceAddressMapping.validate().isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Text(language.lblAvailableAt,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        8.height,
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.start,
            spacing: 8,
            direction: Axis.vertical,
            runSpacing: 8,
            children: List.generate(
              data.serviceAddressMapping!.length,
              (index) {
                ServiceAddressMapping value =
                    data.serviceAddressMapping![index];
                if (value.providerAddressMapping == null) return Offstage();
                bool isSelected = selectedAddressId == index;
                if (selectedBookingAddressId == -1) {
                  selectedBookingAddressId = data
                      .serviceAddressMapping!.first.providerAddressId
                      .validate();
                }
                return GestureDetector(
                  onTap: () {
                    selectedAddressId = index;
                    selectedBookingAddressId =
                        value.providerAddressId.validate();
                    setState(() {});
                  },
                  child: Container(
                    decoration: boxDecorationDefault(
                        color: appStore.isDarkMode
                            ? isSelected
                                ? primaryColor
                                : Colors.black
                            : isSelected
                                ? primaryColor
                                : Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10),
                      child: Text(
                        '${value.providerAddressMapping!.address.validate()}',
                        style: boldTextStyle(
                            color: isSelected
                                ? Colors.white
                                : textPrimaryColorGlobal),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        8.height,
      ],
    );
  }

  Widget providerWidget({required UserData data}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language.lblAboutProvider,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        BookingDetailProviderWidget(providerData: data).onTap(() async {
          await ProviderInfoScreen(providerId: data.id).launch(context);
          setStatusBarColor(Colors.transparent);
        }),
      ],
    ).paddingAll(16);
  }

  Widget serviceFaqWidget({required List<ServiceFaq> data}) {
    if (data.isEmpty) return Offstage();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          8.height,
          ViewAllLabel(label: language.lblFaq, list: data),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: data.length,
            padding: EdgeInsets.all(0),
            itemBuilder: (_, index) =>
                ServiceFaqWidget(serviceFaq: data[index]),
          ),
          8.height,
        ],
      ),
    );
  }

  Widget slotsAvailable(
      {required List<SlotData> data, required bool isSlotAvailable}) {
    if (!isSlotAvailable ||
        data.where((element) => element.slot.validate().isNotEmpty).isEmpty)
      return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.height,
        Text(language.lblAvailableOnTheseDays,
            style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        8.height,
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(
              data
                  .where((element) => element.slot.validate().isNotEmpty)
                  .length, (index) {
            SlotData value = data
                .where((element) => element.slot.validate().isNotEmpty)
                .toList()[index];

            return Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              decoration: boxDecorationDefault(
                color: context.cardColor,
                border: appStore.isDarkMode
                    ? Border.all(color: context.dividerColor)
                    : null,
              ),
              child: Text('${value.day.capitalizeFirstLetter()}',
                  style: secondaryTextStyle(
                      size: LABEL_TEXT_SIZE, color: primaryColor)),
            );
          }),
        ),
        8.height,
      ],
    );
  }

  Widget reviewWidget(
      {required List<RatingData> data,
      required ServiceDetailResponse serviceDetailResponse}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          //label: language.review,
          label:
              '${language.review} (${serviceDetailResponse.serviceDetail!.totalReview})',
          list: data,
          onTap: () {
            RatingViewAllScreen(serviceId: widget.serviceId).launch(context);
          },
        ),
        data.isNotEmpty
            ? Wrap(
                children: List.generate(
                  data.length,
                  (index) => ReviewWidget(data: data[index]),
                ),
              ).paddingTop(8)
            : Text(language.lblNoReviews, style: secondaryTextStyle()),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget relatedServiceWidget(
      {required List<ServiceData> serviceList, required int serviceId}) {
    if (serviceList.isEmpty) return Offstage();

    serviceList.removeWhere((element) => element.id == serviceId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (serviceList.isNotEmpty)
          Text(
            language.lblRelatedServices,
            style: boldTextStyle(size: LABEL_TEXT_SIZE),
          ).paddingSymmetric(horizontal: 16),
        8.height,
        if (serviceList.isNotEmpty)
          ListView.builder(
            padding: EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: serviceList.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) => RelatedServiceComponent(
              serviceData: serviceList[index],
              width: appConfigurationStore.userDashboardType ==
                      DEFAULT_USER_DASHBOARD
                  ? context.width() / 2 - 26
                  : 280,
            ).paddingOnly(bottom: 16, left: 8, right: 8),
          )
      ],
    );
  }

  //endregion

  void bookNow(ServiceDetailResponse serviceDetailResponse) {
    doIfLoggedIn(context, () {
      // If plans exist, user must select one
      if ((serviceDetailResponse.serviceDetail!.plans ?? []).isNotEmpty &&
          selectedPlanId == null) {
        toast("Please select a plan");
        return;
      }

      // If no plans exist, use the service price directly
      if ((serviceDetailResponse.serviceDetail!.plans ?? []).isEmpty) {
        selectedPlanPrice = serviceDetailResponse.serviceDetail!.price.validate().toDouble();
      }

      if (phoneCtrl.text.trim().isEmpty) {
        toast("Please enter a contact number");
        return;
      }

      if (phoneCtrl.text.trim().length != 10 ||
          !RegExp(r'^[0-9]+$').hasMatch(phoneCtrl.text.trim())) {
        toast("Please enter a valid 10-digit number");
        return;
      }

      serviceDetailResponse.serviceDetail!.bookingAddressId =
          selectedBookingAddressId;
      BookServiceScreen(
        data: serviceDetailResponse,
        selectedPackage: selectedPackage,
        bookingType: widget.bookingType,
        customerName: nameCtrl, // pass controller
        customerPhone: phoneCtrl,
        selectedPlanId: selectedPlanId,
        selectedPlanPrice: selectedPlanPrice,
        selectedExtraVehicles: selectedPlans,
        selectedWashWhere: selectedWashWhere,
      ).launch(context).then((value) {
        setStatusBarColor(transparentColor);
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColor(
        widget.isFromProviderInfo ? primaryColor : transparentColor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<ServiceDetailResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return AppScaffold(
          appBarTitle: snap.data!.serviceDetail?.categoryName.validate() ?? '',
          showLoader: false,
          child: Column(
            children: [
              Expanded(
                child: AnimatedScrollView(
                  padding: EdgeInsets.only(bottom: 120),
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  onSwipeRefresh: () async {
                    appStore.setLoading(true);
                    init();
                    setState(() {});
                    return await 2.seconds.delay;
                  },
                  children: [
                    8.height,
                    ServiceDetailHeaderComponent(
                        serviceDetail: snap.data!.serviceDetail!),
                    4.height,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Row(
//                             //   children: [
//                             //     if (snap.data!.serviceDetail!.isOnlineService) ...[OnlineServiceIconWidget(), 10.width],
//                             //     Flexible(
//                             //         child: Container(
//                             //       decoration: BoxDecoration(
//                             //         color: appStore.isDarkMode ? Colors.black : lightPrimaryColor,
//                             //         borderRadius: radius(20),
//                             //       ),
//                             //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                             //       child: Text(
//                             //         (snap.data!.serviceDetail?.categoryName.validate() ?? ' '),
//                             //         maxLines: 1,
//                             //         textAlign: TextAlign.center,
//                             //         overflow: TextOverflow.ellipsis,
//                             //         style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
//                             //       ),
//                             //     )),
//                             //   ],
//                             // ).expand(),
//                             // TextIcon(
//                             //   suffix: Row(
//                             //     children: [
//                             //       Image.asset(
//                             //         ic_star_fill,
//                             //         height: 18,
//                             //         color: getRatingBarColor(snap.data!.serviceDetail!.totalRating.validate().toInt()),
//                             //       ),
//                             //       4.width,
//                             //       Text("${snap.data!.serviceDetail!.totalRating.validate().toStringAsFixed(1)}", style: boldTextStyle()),
//                             //     ],
//                             //   ),
//                             // ),
//                             Text(
//   "${snap.data!.serviceDetail!.categoryName.validate()} wash",
//   style: boldTextStyle(size: 14, color: primaryColor),
// ).paddingSymmetric(horizontal: 16, vertical: 8),
//                           ],
//                         ),
//                         12.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  snap.data!.serviceDetail!.name.validate(),
                                  style: primaryTextStyle(
                                      weight: FontWeight.bold, size: 16),
                                ),
                                if (snap
                                    .data!.serviceDetail!.isOnlineService) ...[
                                  SizedBox(width: 8),
                                  OnlineServiceIconWidget(),
                                ],
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: radius(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                (snap.data!.serviceDetail?.categoryName
                                        .validate() ??
                                    ' '),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        10.height,
                        if (convertToHourMinute(
                                snap.data!.serviceDetail!.duration.validate())
                            .isNotEmpty)
                          Row(
                            children: [
                              Text(language.duration,
                                  style: secondaryTextStyle()),
                              8.width,
                              Text(
                                "${convertToHourMinute(snap.data!.serviceDetail!.duration.validate())}",
                                style: secondaryTextStyle(
                                    weight: FontWeight.bold,
                                    color: textPrimaryColorGlobal),
                              )
                            ],
                          ),
                        10.height,
                        if (snap.data!.serviceDetail!.effectivePrice > 0)
                          Row(
                            children: [
                              if (snap.data!.serviceDetail!.price.validate() == 0 && snap.data!.serviceDetail!.minPlanPrice != null)
                                Text("Starting from ", style: secondaryTextStyle(size: 14)),
                              PriceWidget(
                                size: 18,
                                price: snap.data!.serviceDetail!.effectivePrice,
                                color: primaryColor,
                              ),
                              if (snap.data!.serviceDetail!.discount.validate() > 0) ...[
                                8.width,
                                PriceWidget(
                                  size: 14,
                                  price: snap.data!.serviceDetail!.price.validate(),
                                  isLineThroughEnabled: true,
                                  color: textSecondaryColorGlobal,
                                ),
                                10.width,
                                Text(
                                  "${snap.data!.serviceDetail!.discount.validate()}% ${language.lblOff}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(color: defaultActivityStatus, fontWeight: FontWeight.bold, fontSize: 12),
                                ).expand(),
                              ],
                            ],
                          ),
                        10.height,
                      ],
                    ).paddingSymmetric(horizontal: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rating",
                          style: boldTextStyle(size: 14, color: Colors.white),
                        ),
                        TextIcon(
                          suffix: Row(
                            children: [
                              Image.asset(
                                ic_star_fill,
                                height: 18,
                                color: getRatingBarColor(
                                  snap.data!.serviceDetail!.totalRating
                                      .validate()
                                      .toInt(),
                                ),
                              ),
                              4.width,
                              Text(
                                snap.data!.serviceDetail!.totalRating
                                    .validate()
                                    .toStringAsFixed(1),
                                style: boldTextStyle(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16, vertical: 8),
                    if ((snap.data!.serviceDetail!.plans ?? []).isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select your plan",
                            style: boldTextStyle(size: 16, color: Colors.white),
                          ),
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => AllPlansScreen(
                          //           plans:
                          //               snap.data!.serviceDetail!.plans ?? [],
                          //           selectedPlanId: selectedPlanId!,
                          //           onPlanSelected: (planId, price) {
                          //             setState(() {
                          //               selectedPlanId = planId;
                          //               selectedPlanPrice = price;
                          //             });
                          //           },
                          //         ),
                          //       ),
                          //     );
                          //   },
                          //   child: Text(
                          //     "View All",
                          //     style: primaryTextStyle(
                          //         color: primaryColor, weight: FontWeight.bold),
                          //   ),
                          // ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 8),
                      _plansForModel(snap.data!.serviceDetail!.plans ?? []),
                    ],
                    availableWidget(data: snap.data!.serviceDetail!)
                        .paddingAll(16),

                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (snap.data!.serviceDetail!.galleryImages
                                  .validate()
                                  .isNotEmpty) ...[
                                Text("Gallery", style: boldTextStyle(size: 16)),
                                16.height,
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: snap.data!.serviceDetail!
                                        .galleryImages!.length,
                                    itemBuilder: (context, index) {
                                      return _galleryImg(
                                        context,
                                        index,
                                        snap.data!.serviceDetail!.galleryImages!
                                            .map((e) => e.validate())
                                            .toList(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row Title + Button
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // allows multi-line text
                                    children: [
                                      /// Left Text
                                      Expanded(
                                        child: Text(
                                          "Include Another Vehicles For Washing?",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: appStore.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          softWrap: true,
                                          maxLines:
                                              3, // allows wrapping into 2–3 lines
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      /// Right Button
                                      GestureDetector(
                                        onTap: () async {
                                          final result =
                                              await showModalBottomSheet<
                                                  SelectedVehiclePlan>(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) {
                                              return DraggableScrollableSheet(
                                                expand: false,
                                                initialChildSize: 0.8,
                                                maxChildSize: 0.85,
                                                minChildSize: 0.5,
                                                builder: (context,
                                                    scrollController) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .scaffoldBackgroundColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top:
                                                            Radius.circular(16),
                                                      ),
                                                    ),
                                                    child:
                                                        VehicleSelectorBottomsheet(),
                                                  );
                                                },
                                              );
                                            },
                                          );

                                          if (result != null) {
                                            setState(() {
                                              selectedPlans.add(
                                                  result); // ✅ store selected vehicles
                                            });
                                          }

                                          // showVehicleSelector(context);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                primaryColor,
                                                primaryColor.withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.add_circle_outline,
                                                  color: Colors.white,
                                                  size: 18),
                                              SizedBox(width: 6),
                                              Text(
                                                "Add Extra Vehicles",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Vehicle Cards
                                  Column(
                                    children: selectedPlans
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final plan = entry.value;

                                      return _vehicleCard(
                                        plan,
                                        () {
                                          setState(() {
                                            selectedPlans.removeAt(index);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  )
                                ],
                              ),
                            ])),

                    if (snap.data!.serviceDetail!.description
                        .validate()
                        .isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        "Description",
                        style: boldTextStyle(size: LABEL_TEXT_SIZE),
                      ).paddingOnly(left: 16),
                    ],
                    12.height,
                    Container(
                      width: context.width(),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: radius(),
                        border: appStore.isDarkMode
                            ? Border.all(color: context.dividerColor)
                            : null,
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          snap.data!.serviceDetail!.description
                                  .validate()
                                  .isNotEmpty
                              ? ReadMoreText(
                                  snap.data!.serviceDetail!.description
                                      .validate(),
                                  style: primaryTextStyle(),
                                  colorClickableText: context.primaryColor,
                                  textAlign: TextAlign.justify,
                                )
                              : Text(language.lblNotDescription,
                                  style: primaryTextStyle()),
                          8.height,
                          slotsAvailable(
                            data: snap.data!.serviceDetail!.bookingSlots
                                .validate(),
                            isSlotAvailable:
                                snap.data!.serviceDetail!.isSlotAvailable,
                          ),
                        ],
                      ),
                    ).paddingSymmetric(horizontal: 16, vertical: 8),
                    providerWidget(data: snap.data!.provider!),
                    if (snap.data!.serviceDetail!.servicePackage
                        .validate()
                        .isNotEmpty)
                      PackageComponent(
                        servicePackage:
                            snap.data!.serviceDetail!.servicePackage.validate(),
                        callBack: (v) {
                          if (v != null) {
                            selectedPackage = v;
                          } else {
                            selectedPackage = null;
                          }
                          bookNow(snap.data!);
                        },
                      ),
                    if (snap.data!.serviceaddon.validate().isNotEmpty)
                      AddonComponent(
                        serviceAddon: snap.data!.serviceaddon.validate(),
                        onSelectionChange: (v) {
                          serviceAddonStore.setSelectedServiceAddon(v);
                        },
                      ),
                    serviceFaqWidget(data: snap.data!.serviceFaq.validate())
                        .paddingSymmetric(horizontal: 16),
                    reviewWidget(
                        data: snap.data!.ratingData!,
                        serviceDetailResponse: snap.data!),
                    24.height,
                    if (snap.data!.relatedService.validate().isNotEmpty)
                      relatedServiceWidget(
                        serviceList: snap.data!.relatedService.validate(),
                        serviceId: snap.data!.serviceDetail!.id.validate(),
                      ),
                    12.height,
                    // Personal Details
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Personal Details",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: appStore.isDarkMode
                                        ? Colors.white
                                        : Colors.black))),
                        const SizedBox(height: 16),
                        _inputFieldName("Enter name", nameCtrl),
                        const SizedBox(height: 10),
                        _inputField("Enter mobile number", phoneCtrl),
                      ]),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: appStore.isDarkMode
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 16)],
                      )
                    : null,
                child: AppButton(
                onTap: () {
                  // Instead of calling bookNow directly, show bottom sheet
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: appStore.isDarkMode ? scaffoldColorDark : null,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      String selectedFrequency = "Daily"; // default
                      String selectedLocation = "home"; // default

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "How often do you want a car wash?",
                                      style: boldTextStyle(size: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Frequency option (you can add more later)
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text("Daily",
                                            style: primaryTextStyle())),
                                    Radio<String>(
                                      value: "Daily",
                                      groupValue: selectedFrequency,
                                      onChanged: (value) {
                                        setState(
                                            () => selectedFrequency = value!);
                                      },
                                    )
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Location header
                                Text(
                                  "Where should we wash your car?",
                                  style: boldTextStyle(
                                      size: 16,
                                      color: appStore.isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                const SizedBox(height: 10),

                                // Home option
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedWashWhere = 0; // 0 = Home
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: selectedWashWhere == 0
                                                ? Theme.of(context).primaryColor
                                                : appStore.isDarkMode
                                                    ? quickActionCardBg
                                                    : Color(0xFFE0E0E0),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: appStore.isDarkMode
                                                ? Border.all(
                                                    color: selectedWashWhere == 0
                                                        ? Colors.transparent
                                                        : quickActionCardBorder,
                                                  )
                                                : null,
                                            boxShadow: appStore.isDarkMode && selectedWashWhere == 0
                                                ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 16)]
                                                : null,
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/images/home.png",
                                                    height: 40,
                                                    width: 40,
                                                    color: appStore.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text("At Home",
                                                      style: TextStyle(
                                                          color: appStore.isDarkMode
                                                              ? Colors.white
                                                              : Colors.black)),
                                                ],
                                              ),
                                              if (selectedWashWhere == 0)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedWashWhere = 1; // 1 = Shed
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: selectedWashWhere == 1
                                                ? Theme.of(context).primaryColor
                                                : appStore.isDarkMode
                                                    ? quickActionCardBg
                                                    : Color(0xFFE0E0E0),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: appStore.isDarkMode
                                                ? Border.all(
                                                    color: selectedWashWhere == 1
                                                        ? Colors.transparent
                                                        : quickActionCardBorder,
                                                  )
                                                : null,
                                            boxShadow: appStore.isDarkMode && selectedWashWhere == 1
                                                ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 16)]
                                                : null,
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/images/shed.png",
                                                    height: 40,
                                                    width: 40,
                                                    color: appStore.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text("At Your Shed",
                                                      style: TextStyle(
                                                          color: appStore.isDarkMode
                                                              ? Colors.white
                                                              : Colors.black)),
                                                ],
                                              ),
                                              if (selectedWashWhere == 1)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Confirm button
                                Container(
                                  decoration: appStore.isDarkMode
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 16)],
                                        )
                                      : null,
                                  child: AppButton(
                                    onTap: () {
                                      Navigator.pop(
                                          context); // close bottom sheet
                                      selectedPackage = null;
                                      bookNow(snap
                                          .data!); // 🔥 your original function
                                    },
                                    color: context.primaryColor,
                                    child: Text("Confirm",
                                        style: boldTextStyle(color: white)),
                                    width: context.width(),
                                    textColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                color: context.primaryColor,
                child: Text(language.lblBookNow,
                    style: boldTextStyle(color: white)),
                width: context.width(),
                textColor: Colors.white,
              ),).paddingSymmetric(horizontal: 16.0, vertical: 16.0)
            ],
          ),
        );
      }
      return ServiceDetailShimmer();
    }

    return FutureBuilder<ServiceDetailResponse>(
      initialData: listOfCachedData
          .firstWhere((element) => element?.$1 == widget.serviceId.validate(),
              orElse: () => null)
          ?.$2,
      future: future,
      builder: (context, snap) {
        return Scaffold(
          body: Stack(
            children: [
              buildBodyWidget(snap),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          ),
        );
      },
    );
  }

  Widget _galleryImg(BuildContext context, int index, List<String> images) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(
              images: images,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(images[index]),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  String _vehicleEmoji(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car': return '\u{1F697}';
      case 'bike': return '\u{1F3CD}';
      case 'vans': return '\u{1F690}';
      case 'trucks': return '\u{1F69B}';
      default: return '\u{1F698}';
    }
  }

  Widget _vehicleCard(SelectedVehiclePlan plan, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appStore.isDarkMode ? darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: appStore.isDarkMode
              ? darkBorderGlow.withOpacity(0.5)
              : const Color(0xFFE0E0E0),
        ),
        boxShadow: appStore.isDarkMode
            ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 8)]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Text(_vehicleEmoji(plan.vehicleType), style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plan.vehicleName}  ·  ${plan.model}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: appStore.isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${plan.planName.isNotEmpty ? plan.planName : "Plan"}  ·  ₹${plan.price.toStringAsFixed(0)}/month',
                  style: TextStyle(
                    fontSize: 13,
                    color: appStore.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appStore.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.15),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: appStore.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputFieldName(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        color: appStore.isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: appStore.isDarkMode ? greetingTextColor : Colors.black54,
        ),
        filled: true,
        fillColor: appStore.isDarkMode ? darkSurface : Color(0xFFE0E0E0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: appStore.isDarkMode ? primaryColor : Colors.black,
              width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: appStore.isDarkMode
              ? BorderSide(color: darkBorderGlow.withOpacity(0.3))
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      maxLength: 10,
      style: TextStyle(
        color: appStore.isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        counterText: "",
        hintText: hint,
        hintStyle: TextStyle(
          color: appStore.isDarkMode ? greetingTextColor : Colors.black,
        ),
        filled: true,
        fillColor: appStore.isDarkMode ? darkSurface : Color(0xFFE0E0E0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: appStore.isDarkMode ? primaryColor : Colors.black,
              width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: appStore.isDarkMode
              ? BorderSide(color: darkBorderGlow.withOpacity(0.3))
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _plansForModel(List<ServicePlanData> plans) {
    if (plans.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: plans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          String? badge;
          if (index == 1 && plans.length > 1) badge = 'MOST POPULAR';
          if (index == plans.length - 1 && plans.length > 2) badge = 'BEST VALUE';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _planCard(plan, badge: badge),
          );
        }).toList(),
      ),
    );
  }

  Widget _planCard(ServicePlanData plan, {String? badge}) {
    final planId = plan.id ?? 0;
    final isSelected = selectedPlanId == planId;
    final amount = plan.amount ?? '0';
    final title = plan.name ?? 'Plan';
    final items = plan.items ?? [];
    final washType = plan.washType ?? '';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanId = planId;
          selectedPlanPrice = double.tryParse(amount) ?? 0;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : appStore.isDarkMode
                    ? darkBorderGlow.withOpacity(0.5)
                    : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: context.primaryColor.withOpacity(0.15), blurRadius: 12)]
              : appStore.isDarkMode
                  ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 12)]
                  : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badge == 'MOST POPULAR'
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badge == 'MOST POPULAR' ? Colors.orange[700] : Colors.green[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Title & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: appStore.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Text(
                  '₹$amount/month',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.primaryColor,
                  ),
                ),
              ],
            ),

            // Wash info row
            if (washType.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.autorenew, size: 16, color: appStore.isDarkMode ? Colors.white70 : Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    '$washType washes/month',
                    style: TextStyle(
                      fontSize: 13,
                      color: appStore.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 10),

            // Feature list
            ...items.map((item) {
              final isActive = item.status == 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isActive ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: isActive ? Colors.green : Colors.red.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: appStore.isDarkMode ? Colors.white : Colors.black87,
                          decoration: isActive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Selection indicator
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 20,
                    color: isSelected ? context.primaryColor : (appStore.isDarkMode ? Colors.white54 : Colors.black38),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSelected ? 'Selected' : 'Select',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? context.primaryColor : (appStore.isDarkMode ? Colors.white54 : Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: Image.network(
                    rewriteImageUrl(widget.images[index]),
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.95, // bigger
                    height: MediaQuery.of(context).size.height * 0.85,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
