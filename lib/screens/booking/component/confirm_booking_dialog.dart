import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/package_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../model/booking_amount_model.dart';
import '../../../utils/app_configuration.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../payment/payment_screen.dart';
import 'booking_confirmation_dialog.dart';

class ConfirmBookingDialog extends StatefulWidget {
  final ServiceDetailResponse data;
  final num? bookingPrice;
  final int qty;
  final String? couponCode;
  final BookingPackage? selectedPackage;
  final BookingAmountModel? bookingAmountModel;
  final String bookingType;
  final String customerName;  // new
  final String customerPhone;
  final int? selectedPlanId;
  final List<SelectedVehiclePlan> selectedExtraVehicles;
  final int selectedWashWhere;

  ConfirmBookingDialog({required this.data, required this.bookingPrice, this.qty = 1, this.couponCode, this.selectedPackage, this.bookingAmountModel, required this.bookingType,required this.customerName,
    required this.customerPhone, this.selectedPlanId, this.selectedExtraVehicles = const [],this.selectedWashWhere = 0,});

  @override
  State<ConfirmBookingDialog> createState() => _ConfirmBookingDialogState();
}

class _ConfirmBookingDialogState extends State<ConfirmBookingDialog> {
  Map? selectedPackage;
  List<int> selectedService = [];

  bool isSelected = false;

  Future<void> bookServices() async {
    if (widget.selectedPackage != null) {
      if (widget.selectedPackage!.serviceList != null) {
        widget.selectedPackage!.serviceList!.forEach((element) {
          selectedService.add(element.id.validate());
        });
      }

      selectedPackage = {
        PackageKey.packageId: widget.selectedPackage!.id.validate(),
        PackageKey.categoryId: widget.selectedPackage!.categoryId != -1 ? widget.selectedPackage!.categoryId.validate() : null,
        PackageKey.name: widget.selectedPackage!.name.validate(),
        PackageKey.price: widget.selectedPackage!.price.validate(),
        PackageKey.serviceId: selectedService.join(','),
        PackageKey.startDate: widget.selectedPackage!.startDate.validate(),
        PackageKey.endDate: widget.selectedPackage!.endDate.validate(),
        PackageKey.isFeatured: widget.selectedPackage!.isFeatured == 1 ? '1' : '0',
        PackageKey.packageType: widget.selectedPackage!.packageType.validate(),
      };
    }

    log("selectedPackage: ${[selectedPackage]}");

    Map request = {
      CommonKeys.id: "",
      CommonKeys.serviceId: widget.data.serviceDetail!.id.toString(),
      CommonKeys.providerId: widget.data.provider!.id.validate().toString(),
      CommonKeys.customerId: appStore.userId.toString().toString(),
      BookingServiceKeys.description: widget.data.serviceDetail!.bookingDescription.validate().toString(),
      CommonKeys.address: widget.data.serviceDetail!.address.validate().toString(),
      CommonKeys.date: widget.data.serviceDetail!.isSlotAvailable ? widget.data.serviceDetail!.bookingDate.validate().toString() : widget.data.serviceDetail!.dateTimeVal.validate().toString(),
      BookingServiceKeys.couponId: widget.couponCode.validate(),
      // BookService.amount: widget.selectedPackage != null ? widget.selectedPackage!.price : widget.data.serviceDetail!.price,
      BookService.amount: widget.selectedPackage != null ? widget.selectedPackage!.price : widget.bookingPrice,
      BookService.quantity: '${widget.qty}',
      BookingServiceKeys.totalAmount: !widget.data.serviceDetail!.isFreeService ? widget.bookingPrice.validate().toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS)) : 0,
      CouponKeys.discount: widget.data.serviceDetail!.discount != null ? widget.data.serviceDetail!.discount.toString() : "",
      BookService.bookingAddressId: widget.data.serviceDetail!.bookingAddressId != -1 ? widget.data.serviceDetail!.bookingAddressId : null,
      BookingServiceKeys.type: BOOKING_TYPE_SERVICE,
      BookingServiceKeys.bookingPackage: widget.selectedPackage != null ? selectedPackage : null,
      BookingServiceKeys.serviceAddonId: serviceAddonStore.selectedServiceAddon.map((e) => e.id).toList(),
      "booking_type": widget.bookingType,
      "customer_name": widget.customerName,
  "customer_phone": widget.customerPhone,
  "service_plan_id": widget.selectedPlanId ?? 0,
  "extra_vehicles": widget.selectedExtraVehicles.map((e) => {
    'service_id': e.serviceId ?? widget.data.serviceDetail!.id,
    'service_plan_id': e.planId,
    'quantity': 1,
    'price': double.tryParse(e.price.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
    'vehicle_name': e.vehicleName,
    'vehicle_type': e.vehicleType,
    'vehicle_model': e.model,
  }).toList(),
  "booking_at": widget.selectedWashWhere == 0 ? "home" : "shed",
    };
    if (widget.bookingAmountModel != null) {
      request.addAll(widget.bookingAmountModel!.toJson());
    }

    if (widget.data.serviceDetail!.isSlotAvailable) {
      request.putIfAbsent('booking_date', () => widget.data.serviceDetail!.bookingDate.validate().toString());
      request.putIfAbsent('booking_slot', () => widget.data.serviceDetail!.bookingSlot.validate().toString());
      request.putIfAbsent('booking_day', () => widget.data.serviceDetail!.bookingDay.validate().toString());
    }

    if (!widget.data.serviceDetail!.isFreeService && widget.data.taxes.validate().isNotEmpty) {
      request.putIfAbsent('tax', () => widget.data.taxes);
    }
    if (widget.data.serviceDetail != null && widget.data.serviceDetail!.isAdvancePayment && !widget.data.serviceDetail!.isFreeService && widget.data.serviceDetail!.isFixedService) {
      request.putIfAbsent(CommonKeys.status, () => BookingStatusKeys.waitingAdvancedPayment);
    }

    appStore.setLoading(true);

    saveBooking(request).then((bookingDetailResponse) async {
      appStore.setLoading(false);

      if (widget.data.serviceDetail != null && widget.data.serviceDetail!.isAdvancePayment && !widget.data.serviceDetail!.isFreeService && widget.data.serviceDetail!.isFixedService) {
        finish(context);
        PaymentScreen(bookings: bookingDetailResponse, isForAdvancePayment: true).launch(context);
      } else {
        finish(context);
        showInDialog(
          context,
          barrierDismissible: false,
          builder: (BuildContext context) => BookingConfirmationDialog(
            data: widget.data,
            bookingId: bookingDetailResponse.bookingDetail!.id,
            bookingPrice: widget.bookingPrice,
            selectedPackage: widget.selectedPackage,
            bookingDetailResponse: bookingDetailResponse,
          ),
          backgroundColor: transparentColor,
          contentPadding: EdgeInsets.zero,
        );
      }
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;

    return Observer(
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.event_available_rounded, color: context.primaryColor, size: 24),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(language.lblConfirmBooking, style: boldTextStyle(size: 18)),
                      4.height,
                      Text(language.wouldYouLikeTo, style: secondaryTextStyle(size: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => finish(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 18, color: isDark ? Colors.white54 : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            20.height,

            // Booking details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? context.dividerColor : const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service / Package
                  if (widget.selectedPackage == null)
                    _confirmDetailRow(Icons.local_car_wash_rounded, language.serviceName, widget.data.serviceDetail?.name.validate() ?? "")
                  else
                    _confirmDetailRow(Icons.inventory_2_outlined, language.packageName, widget.selectedPackage?.name.validate() ?? ""),

                  // Plan
                  if (widget.selectedPlanId != null && widget.data.serviceDetail?.plans != null)
                    Builder(builder: (_) {
                      final plan = widget.data.serviceDetail!.plans!.firstWhere(
                        (p) => p.id == widget.selectedPlanId,
                        orElse: () => ServicePlanData(),
                      );
                      if (plan.name != null) return _confirmDetailRow(Icons.workspace_premium_rounded, "Plan", plan.name!);
                      return SizedBox();
                    }),

                  // Date & Time
                  _confirmDetailRow(
                    Icons.calendar_today_rounded,
                    language.lblDateAndTime,
                    widget.data.serviceDetail!.isSlotAvailable
                        ? getConfirmBookingDateFormat(date: "${widget.data.serviceDetail!.bookingDate} ${widget.data.serviceDetail!.bookingSlot}")
                        : getConfirmBookingDateFormat(date: widget.data.serviceDetail!.dateTimeVal.validate()),
                  ),

                  // Wash location
                  _confirmDetailRow(
                    widget.selectedWashWhere == 0 ? Icons.home_rounded : Icons.warehouse_rounded,
                    "Wash At",
                    widget.selectedWashWhere == 0 ? "Home" : "Shed",
                  ),

                  // Price
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withOpacity(isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount", style: boldTextStyle(size: 14)),
                          Text(
                            widget.data.serviceDetail!.isFreeService
                                ? "Free"
                                : '₹${widget.bookingPrice.validate().toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS))}',
                            style: boldTextStyle(size: 16, color: context.primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Extra vehicles
                  if (widget.selectedExtraVehicles.isNotEmpty) ...[
                    12.height,
                    Text("Extra Vehicles", style: boldTextStyle(size: 13, color: isDark ? Colors.white70 : Colors.grey.shade700)),
                    8.height,
                    ...widget.selectedExtraVehicles.map((ev) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car_outlined, size: 14, color: context.primaryColor),
                          8.width,
                          Expanded(child: Text(ev.vehicleName, style: primaryTextStyle(size: 12))),
                          Text('₹${ev.price.toStringAsFixed(0)}', style: boldTextStyle(size: 12, color: context.primaryColor)),
                        ],
                      ),
                    )),
                  ],

                  // Advance payment
                  if (widget.data.serviceDetail!.isAdvancePayment && !widget.data.serviceDetail!.isFreeService && widget.data.serviceDetail!.isFixedService)
                    Builder(builder: (_) {
                      final pct = widget.data.serviceDetail!.advancePaymentPercentage.validate();
                      final advAmt = (widget.bookingPrice.validate() * pct / 100);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.payment_rounded, size: 16, color: Colors.orange),
                            8.width,
                            Text("Advance (${pct.toStringAsFixed(0)}%)", style: secondaryTextStyle(size: 12)),
                            const Spacer(),
                            Text(
                              '₹${advAmt.toStringAsFixed(getIntAsync(PRICE_DECIMAL_POINTS))}',
                              style: boldTextStyle(size: 12, color: Colors.orange),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Cancellation notice
            if (!widget.data.serviceDetail!.isFreeService && appConfigurationStore.cancellationCharge) ...[
              12.height,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(isDark ? 0.08 : 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: Colors.red.shade400),
                    8.width,
                    Expanded(
                      child: Text(
                        '${language.a} ${appConfigurationStore.cancellationChargeAmount}% ${language.feeAppliesForCancellations} ${appConfigurationStore.cancellationChargeHours} ${language.hoursOfTheScheduled}',
                        style: secondaryTextStyle(size: 11, color: Colors.red.shade400, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            16.height,

            // Terms checkbox
            ExcludeSemantics(
              child: CheckboxListTile(
                checkboxShape: RoundedRectangleBorder(borderRadius: radius(4)),
                autofocus: false,
                activeColor: context.primaryColor,
                checkColor: isDark ? context.iconColor : context.cardColor,
                value: isSelected,
                onChanged: (val) async {
                  isSelected = !isSelected;
                  setState(() {});
                },
                title: RichTextWidget(
                  list: [
                    TextSpan(text: '${language.byConfirmingYouAgree} ', style: secondaryTextStyle(size: 13, fontFamily: fontFamilySecondaryGlobal)),
                    TextSpan(
                      text: language.lblTermsOfService,
                      style: boldTextStyle(color: primaryColor, size: 13),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          checkIfLink(context, appConfigurationStore.termConditions, title: language.termsCondition);
                        },
                    ),
                    TextSpan(text: ' ${language.and} ', style: secondaryTextStyle(size: 13)),
                    TextSpan(
                      text: language.privacyPolicy,
                      style: boldTextStyle(color: primaryColor, size: 13),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          checkIfLink(context, appConfigurationStore.privacyPolicy, title: language.privacyPolicy);
                        },
                    ),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            24.height,

            // Confirm button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isSelected
                    ? LinearGradient(colors: [context.primaryColor, context.primaryColor.withOpacity(0.85)])
                    : null,
                color: isSelected ? null : (isDark ? Colors.white10 : Colors.grey.shade200),
                boxShadow: isSelected
                    ? [BoxShadow(color: context.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (isSelected) {
                      bookServices();
                    } else {
                      toast(language.termsConditionsAccept);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.grey), size: 20),
                        8.width,
                        Text(
                          language.confirm,
                          style: boldTextStyle(
                            size: 16,
                            color: isSelected ? Colors.white : (isDark ? Colors.white38 : Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            8.height,
            TextButton(
              onPressed: () => finish(context),
              child: Text(language.lblCancel, style: boldTextStyle(size: 14, color: isDark ? Colors.white54 : Colors.grey.shade600)),
            ),
          ],
        ).visible(
          !appStore.isLoading,
          defaultWidget: LoaderWidget().withSize(width: 250, height: 280),
        );
      },
    );
  }

  Widget _confirmDetailRow(IconData icon, String label, String value) {
    final isDark = appStore.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: context.primaryColor),
          ),
          10.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: secondaryTextStyle(size: 11, color: isDark ? Colors.white38 : Colors.grey.shade500)),
                3.height,
                Text(value, style: boldTextStyle(size: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

