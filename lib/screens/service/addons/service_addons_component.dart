import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/cached_image_widget.dart';
import '../../../component/price_widget.dart';
import '../../../component/view_all_label_component.dart';
import '../../../main.dart';
import '../../../model/service_detail_response.dart';

class AddonComponent extends StatefulWidget {
  final List<Serviceaddon> serviceAddon;
  final Function(List<Serviceaddon>)? onSelectionChange;
  final bool isFromBookingLastStep;
  final bool isFromBookingDetails;
  final bool showDoneBtn;
  final Function(Serviceaddon)? onDoneClick;

  AddonComponent({
    required this.serviceAddon,
    this.isFromBookingLastStep = false,
    this.isFromBookingDetails = false,
    this.onSelectionChange,
    this.showDoneBtn = false,
    this.onDoneClick,
  });

  @override
  _AddonComponentState createState() => _AddonComponentState();
}

class _AddonComponentState extends State<AddonComponent> {
  List<Serviceaddon> selectedServiceAddon = [];
  double imageHeight = 60;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceAddon.isEmpty) return Offstage();

    bool isSingleAddon = widget.serviceAddon.length == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: language.addOns,
          list: [],
          onTap: () {},
        ),
        isSingleAddon
            ? buildSingleAddonWidget(widget.serviceAddon[0])
            : buildMultipleAddonsWidget(),
      ],
    ).paddingSymmetric(
      horizontal:
          widget.isFromBookingLastStep || widget.isFromBookingDetails ? 0 : 16,
    );
  }

  Widget buildSingleAddonWidget(Serviceaddon addon) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(
        border: appStore.isDarkMode
            ? Border.all(color: context.dividerColor)
            : null,
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🔹 Image (1st column)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: addon.serviceAddonImage.isNotEmpty
                ? Image.network(
                    rewriteImageUrl(addon.serviceAddonImage),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey),
                  )
                : Icon(Icons.image, size: 50, color: Colors.grey),
          ),

          const SizedBox(width: 12),

          /// 🔹 Name + Price (2nd column)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(
                    addon.name.validate(),
                    style: boldTextStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                PriceWidget(
                  price: addon.price.validate(),
                  hourlyTextColor: Colors.white,
                  size: 12,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// 🔹 Add/Remove Button (3rd column)
          if (!widget.isFromBookingDetails) buildAddButton(addon),
        ],
      ),
    );
  }

  Widget buildMultipleAddonsWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 👈 vertical scrolling
      child: Column(
        children: List.generate(
          widget.serviceAddon.length,
          (i) {
            Serviceaddon data = widget.serviceAddon[i];
            return Observer(builder: (context) {
              return GestureDetector(
                onTap: () {
                  if (!widget.isFromBookingLastStep &&
                      !widget.isFromBookingDetails) {
                    handleAddRemove(data);
                  }
                },
                behavior: HitTestBehavior.translucent,
                child: buildAddonContainer(data),
              );
            });
          },
        ),
      ),
    );
  }

  Widget buildAddonContainer(Serviceaddon data) {
    return Container(
      width: context.isPhone() ? double.infinity : 300,
      margin: EdgeInsets.only(right: context.isPhone() ? 0 : 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: boxDecorationWithRoundedCorners(
        border: appStore.isDarkMode
            ? Border.all(color: context.dividerColor)
            : null,
        borderRadius: radius(),
        backgroundColor: context.cardColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🔹 Image (1st column)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: data.serviceAddonImage.isNotEmpty
                ? Image.network(
                    rewriteImageUrl(data.serviceAddonImage),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey),
                  )
                : Icon(Icons.image, size: 50, color: Colors.grey),
          ),

          const SizedBox(width: 12),

          /// 🔹 Name + Price (2nd column)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(
                    data.name.validate(),
                    style: boldTextStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                PriceWidget(
                  price: data.price.validate(),
                  hourlyTextColor: Colors.white,
                  size: 12,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// 🔹 Add/Remove Button (3rd column)
          if (!widget.isFromBookingDetails) buildAddButton(data),
        ],
      ),
    );
  }

  Widget buildAddButton(Serviceaddon data) {
    return GestureDetector(
      onTap: () => handleAddRemove(data),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.transparent, // optional background
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          data.isSelected
              ? Icons.check_box_rounded // ✅ Selected
              : Icons.check_box_outline_blank, // ⬜ Not selected
          color: data.isSelected ? context.primaryColor : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  void handleAddRemove(Serviceaddon data) {
    data.isSelected = !data.isSelected;
    selectedServiceAddon =
        widget.serviceAddon.where((p0) => p0.isSelected).toList();
    widget.onSelectionChange?.call(selectedServiceAddon);
    setState(() {});
  }
}
