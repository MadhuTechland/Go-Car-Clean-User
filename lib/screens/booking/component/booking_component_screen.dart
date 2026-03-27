import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/service_detail_response.dart';

class BookingComponent extends StatelessWidget {
  final BookingData bookingData;

  const BookingComponent({super.key, required this.bookingData});

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return pending;
      case 'accept':
      case 'accepted':
        return accept;
      case 'on_going':
      case 'ongoing':
        return on_going;
      case 'in_progress':
        return in_progress;
      case 'hold':
        return hold;
      case 'cancelled':
        return cancelled;
      case 'rejected':
        return rejected;
      case 'failed':
        return failed;
      case 'completed':
        return completed;
      case 'pending_approval':
        return pendingApprovalColor;
      case 'waiting':
      case 'waiting_advanced_payment':
        return waiting;
      default:
        return defaultStatus;
    }
  }

  String _statusLabel(String? status) {
    if (status == null || status.isEmpty) return "Pending";
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accept':
      case 'accepted':
        return 'Accepted';
      case 'on_going':
      case 'ongoing':
        return 'Ongoing';
      case 'in_progress':
        return 'In Progress';
      case 'hold':
        return 'On Hold';
      case 'cancelled':
        return 'Cancelled';
      case 'rejected':
        return 'Rejected';
      case 'failed':
        return 'Failed';
      case 'completed':
        return 'Completed';
      case 'pending_approval':
        return 'Pending Approval';
      case 'waiting':
        return 'Waiting';
      case 'waiting_advanced_payment':
        return 'Awaiting Payment';
      default:
        return status.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '').join(' ');
    }
  }

  String _paymentLabel(String? status) {
    if (status == null || status.isEmpty) return "Pending";
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'unpaid':
        return 'Unpaid';
      case 'advanced_paid':
        return 'Advance Paid';
      case 'refunded':
        return 'Refunded';
      default:
        return status.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : '').join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;
    final statusClr = _statusColor(bookingData.status);
    final bool hasExtras = (bookingData.extraVehicles != null && bookingData.extraVehicles!.isNotEmpty) ||
        (bookingData.serviceaddon != null && bookingData.serviceaddon!.isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? darkBorderGlow.withValues(alpha: 0.4) : Colors.grey.shade200,
        ),
        boxShadow: isDark
            ? [BoxShadow(color: primaryColor.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status accent bar + Booking ID + Status
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: statusClr.withValues(alpha: isDark ? 0.1 : 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? darkBorderGlow.withValues(alpha: 0.2) : Colors.grey.shade100,
                ),
              ),
            ),
            child: Row(
              children: [
                // Left accent dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusClr,
                    shape: BoxShape.circle,
                  ),
                ),
                10.width,
                Text(
                  'Booking #${bookingData.id ?? '—'}',
                  style: boldTextStyle(size: 13, color: isDark ? Colors.white70 : Colors.grey.shade700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusClr.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusClr.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _statusLabel(bookingData.status),
                    style: boldTextStyle(size: 11, color: statusClr),
                  ),
                ),
              ],
            ),
          ),

          // Body content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service name
                Text(
                  bookingData.serviceName ?? 'Service',
                  style: boldTextStyle(size: 16, color: isDark ? Colors.white : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                8.height,

                // Plan + Price row
                Row(
                  children: [
                    if (bookingData.plan != null && bookingData.plan!.name != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bookingData.plan!.name!,
                          style: boldTextStyle(size: 11, color: primaryColor),
                        ),
                      ),
                      10.width,
                    ],
                    Text(
                      bookingData.amount != null ? bookingData.amount!.toPriceFormat() : '—',
                      style: boldTextStyle(size: 15, color: primaryColor),
                    ),
                    if (bookingData.discount != null && bookingData.discount! > 0) ...[
                      8.width,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${bookingData.discount}% OFF',
                          style: boldTextStyle(size: 10, color: Colors.green),
                        ),
                      ),
                    ],
                  ],
                ),
                14.height,

                // Info rows with better styling
                _infoRow(
                  context,
                  icon: Icons.calendar_today_rounded,
                  label: bookingData.date ?? '—',
                  iconColor: const Color(0xFF1B3A5C),
                ),
                8.height,
                _infoRow(
                  context,
                  icon: Icons.person_outline_rounded,
                  label: _buildCustomerText(),
                  iconColor: const Color(0xFF10B981),
                ),
                if (bookingData.address != null && bookingData.address!.isNotEmpty) ...[
                  8.height,
                  _infoRow(
                    context,
                    icon: Icons.location_on_outlined,
                    label: bookingData.address!,
                    maxLines: 1,
                    iconColor: const Color(0xFFF59E0B),
                  ),
                ],
                8.height,
                _infoRow(
                  context,
                  icon: bookingData.bookingAt == 'shed' ? Icons.warehouse_outlined : Icons.home_outlined,
                  label: bookingData.bookingAt == 'shed' ? 'At Shed' : 'At Home',
                  iconColor: const Color(0xFFEC4899),
                ),
              ],
            ),
          ),

          // Footer: Payment + Extras
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: isDark ? darkSurface.withValues(alpha: 0.5) : const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
              border: Border(
                top: BorderSide(
                  color: isDark ? darkBorderGlow.withValues(alpha: 0.15) : Colors.grey.shade100,
                ),
              ),
            ),
            child: Row(
              children: [
                // Payment status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _paymentColor(bookingData.paymentStatus).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _paymentIcon(bookingData.paymentStatus),
                        size: 13,
                        color: _paymentColor(bookingData.paymentStatus),
                      ),
                      5.width,
                      Text(
                        _paymentLabel(bookingData.paymentStatus),
                        style: boldTextStyle(
                          size: 11,
                          color: _paymentColor(bookingData.paymentStatus),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Extra info chips
                if (hasExtras)
                  Row(
                    children: [
                      if (bookingData.extraVehicles != null && bookingData.extraVehicles!.isNotEmpty)
                        _chip(context, '+${bookingData.extraVehicles!.length} vehicles'),
                      if (bookingData.serviceaddon != null && bookingData.serviceaddon!.isNotEmpty) ...[
                        4.width,
                        _chip(context, '+${bookingData.serviceaddon!.length} addons'),
                      ],
                    ],
                  ),
                // Arrow indicator
                if (!hasExtras)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildCustomerText() {
    final name = bookingData.customersName ?? bookingData.customerName;
    final phone = bookingData.customerPhone;
    if (name != null && phone != null && phone.isNotEmpty) {
      return '$name · $phone';
    }
    return name ?? '—';
  }

  Widget _infoRow(BuildContext context, {required IconData icon, required String label, int maxLines = 1, Color? iconColor}) {
    final isDark = appStore.isDarkMode;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: (iconColor ?? primaryColor).withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 14, color: iconColor ?? (isDark ? greetingTextColor : appTextSecondaryColor)),
        ),
        10.width,
        Expanded(
          child: Text(
            label,
            style: primaryTextStyle(size: 13, color: isDark ? Colors.white70 : Colors.grey.shade700),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: boldTextStyle(size: 10, color: context.primaryColor)),
    );
  }

  IconData _paymentIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Icons.check_circle_outline;
      case 'advanced_paid':
        return Icons.schedule;
      case 'refunded':
        return Icons.replay;
      default:
        return Icons.pending_outlined;
    }
  }

  Color _paymentColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return completed;
      case 'advanced_paid':
        return waiting;
      case 'unpaid':
        return pending;
      case 'refunded':
        return Colors.orange;
      default:
        return hold;
    }
  }
}

class AddonsScreen extends StatelessWidget {
  final List<Serviceaddon> addons;

  const AddonsScreen({Key? key, required this.addons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text("Service Addons")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addons.length,
        itemBuilder: (context, index) {
          final addon = addons[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? darkBorderGlow.withValues(alpha: 0.3) : borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: addon.serviceAddonImage.isNotEmpty
                          ? Image.network(rewriteImageUrl(addon.serviceAddonImage), height: 100, fit: BoxFit.cover)
                          : Container(
                              height: 100,
                              color: isDark ? quickActionCardBg : cardColor,
                              child: const Icon(Icons.extension, size: 32, color: appTextSecondaryColor),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(addon.name, style: boldTextStyle(size: 14, color: context.primaryColor)),
                        8.height,
                        Text(
                          num.tryParse(addon.price.toString())?.toPriceFormat() ?? addon.price.toString(),
                          style: boldTextStyle(size: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExtraVehiclesScreen extends StatelessWidget {
  final List<ExtraVehicle> vehicles;

  const ExtraVehiclesScreen({Key? key, required this.vehicles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text("Extra Vehicles")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? darkBorderGlow.withValues(alpha: 0.3) : borderColor),
            ),
            child: Row(
              children: [
                // Vehicle image
                if (vehicle.serviceImages != null && vehicle.serviceImages!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      rewriteImageUrl(vehicle.serviceImages!.first),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: isDark ? quickActionCardBg : cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car, size: 32, color: appTextSecondaryColor),
                  ),
                12.width,
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleName ?? vehicle.serviceName ?? 'Vehicle',
                        style: boldTextStyle(size: 15, color: context.primaryColor),
                      ),
                      if (vehicle.vehicleType != null) ...[
                        4.height,
                        Text(vehicle.vehicleType!, style: secondaryTextStyle(size: 12)),
                      ],
                      6.height,
                      if (vehicle.planName != null)
                        Text('Plan: ${vehicle.planName}', style: secondaryTextStyle(size: 12)),
                      4.height,
                      Text(
                        num.tryParse(vehicle.price.toString())?.toPriceFormat() ?? vehicle.price.toString(),
                        style: boldTextStyle(size: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
