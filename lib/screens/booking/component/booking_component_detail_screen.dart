import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/dotted_line.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class DetailedBookingScreen extends StatelessWidget {
  final BookingData bookingData;

  const DetailedBookingScreen({super.key, required this.bookingData});

  Widget _buildRow(String title, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    
String datePart = "";
String timePart = "";

if (bookingData.bookingDate != null && bookingData.bookingDate!.isNotEmpty) {
  DateTime parsedDate = DateFormat("MMMM d, yyyy h:mm a").parse(bookingData.bookingDate!);

  datePart = DateFormat("MMMM d, yyyy").format(parsedDate); // September 18, 2025
  timePart = DateFormat("h:mm a").format(parsedDate);       // 6:58 PM
}
    return Scaffold(
        backgroundColor: appStore.isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          title: Text(bookingData.status ?? "Pending",
              style: TextStyle(
                  color: Colors.white)),
          actions: [
//             TextButton(
//   onPressed: () {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // disable tap outside to close
//       barrierColor: appStore.isDarkMode ? Colors.white : Colors.black.withOpacity(0.5),
//       builder: (BuildContext context) {
//         return Dialog(
//           insetPadding: const EdgeInsets.all(16), // full width look
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           backgroundColor: Colors.black,
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // expand based on content
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Row
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Request Invoice",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.black),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),

//               // Body
//               Container(
//                 color: Colors.transparent,
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Enter the email address where you wish to receive your invoice",
//                       style: TextStyle(fontSize: 14, color: appStore.isDarkMode ? Colors.white : Colors.black),
//                     ),
//                     const SizedBox(height: 12),

//                     // Email TextField
//                     TextField(
//                       decoration: InputDecoration(
//                         hintText: "saul@user.com",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 14,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Send Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).primaryColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: () {
//                           // 👉 Handle send logic
//                           Navigator.pop(context);
//                         },
//                         child: const Text(
//                           "Send",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   },
//   child: const Text(
//     "Check Status",
//     style: TextStyle(
//       color: appStore.isDarkMode ? Colors.white : Colors.black,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
// )
TextButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      barrierColor: appStore.isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      backgroundColor: appStore.isDarkMode ? Colors.black : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        List<TimelineEvent> timeline = [
          TimelineEvent(
            time: "1:17 PM",
            date: "6 Feb",
            title: "New Booking",
            subtitle: "New booking added by customer",
            color: Colors.blue,
          ),
          TimelineEvent(
            time: "1:17 PM",
            date: "6 Feb",
            title: "Accepted Booking",
            subtitle: "Status changed from pending to accepted",
            color: Colors.green,
          ),
          TimelineEvent(
            time: "3:00 PM",
            date: "6 Feb",
            title: "Ongoing Booking",
            subtitle: "Status changed from accepted to ongoing",
            color: Colors.orange,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    "Booking History",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: appStore.isDarkMode ? Colors.white : Colors.black),
                  ),
                  Text(
                    "ID: #123",
                    style: TextStyle(fontSize: 14, color: context.primaryColor,
                                    )                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 16),

              // Timeline Column
              Column(
                children: List.generate(timeline.length, (index) {
                  final e = timeline[index];
                  final isLast = index == timeline.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Time & Date Column
                      SizedBox(
                        width: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.time,
                                style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(e.date,
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 🔹 Timeline Dots & Line
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: e.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
  DottedLine(
    direction: Axis.vertical,
    lineLength: 60,
    dashLength: 4,
    dashGapLength: 4,
    lineThickness: 2,
    dashColor: Colors.grey,
  ),

                        ],
                      ),

                      const SizedBox(width: 16),

                      // 🔹 Event Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title,
                                style: TextStyle(color: e.color, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(e.subtitle,
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  },
  child: Text(
    "Check Status",
    style: TextStyle(
      color: appStore.isDarkMode ? Colors.white : Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
)
          ],
        ),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if ((bookingData.status ?? "").toLowerCase() == "pending")
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color:
                    const Color.fromARGB(255, 57, 30, 30), // light red banner
                child: const Text(
                  "Waiting for provider approval",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // add spacing after banner
            if ((bookingData.status ?? "").toLowerCase() == "pending")
              16.height,

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Booking ID",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("#${bookingData.id ?? '12345'}",
                          style: TextStyle(color: context.primaryColor)),
                    ],
                  ),
                  8.height,
                  Divider(color: Colors.grey, thickness: 0.2, height: 24),
                  12.height,

                  // Vehicle details
                  Text("SUV",
                      style:
                          TextStyle(fontSize: 16, color: context.primaryColor)),
                  Text(bookingData.serviceName ?? "-",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  16.height,

                  // Service Details Card
                  Card(
                    color: Colors.transparent, // removes white background
                    elevation: 0, // removes shadow

                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Column 1: Labels
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Date"),
                                  SizedBox(height: 8),
                                  Text("Time"),
                                  SizedBox(height: 8),
                                Text("Wash Type"),
                                SizedBox(height: 8),
                                Text("Location Type"),
                                SizedBox(height: 8),
                                Text("Plan"),
                              ],
                            ),
                          ),
                          // Column 2: Values
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
  Text(
    datePart.isNotEmpty ? datePart : "—",
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
  const SizedBox(height: 8),
  Text(
    timePart.isNotEmpty ? timePart : "—",
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
  const SizedBox(height: 8),
  const Text(
    "Instant Wash",
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
  const SizedBox(height: 8),
  const Text(
    "At Home",
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
  const SizedBox(height: 8),
  const Text(
    "Basic Plan ₹299",
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),

                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // 👈 vertical centering
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      12), // 👈 rounded corners
                                  child: CachedImageWidget(
  url: bookingData.serviceAttachments != null && bookingData.serviceAttachments!.isNotEmpty
      ? bookingData.serviceAttachments!.first
      : "",
  height: 108,
  width: 110,
  fit: BoxFit.cover,
),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        (bookingData.status ?? "").toLowerCase() == "ongoing",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Booking Description",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: appStore.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bookingData.description ?? "No description provided",
                          style:  TextStyle(
                            fontSize: 14,
                            color: appStore.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  16.height,
                 Text("Addons",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appStore.isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 10),
                  _addonItem(model1_image, "AC Vent Cleaning", "₹100.00"),
                  _addonItem(
                      model2_image, "Leather Seat Conditioning", "₹100.00"),
                  16.height,
                  Text('Preferences',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Column(
                    children: [
                      _vehicleCard("Bike", "---", "---", "₹200"),
                      _vehicleCard("Car", "Swift", "VXI", "₹400"),
                    ],
                  ),
                  16.height,
                  Visibility(
                    visible: (bookingData.status ?? "").toLowerCase() ==
                            "pending" ||
                        (bookingData.status ?? "").toLowerCase() == "ongoing",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About Us",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // About Us Card
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name (just text, no label)
                                Text(
                                  bookingData.customerName ?? "John Doe",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: appStore.isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Location with icon
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        bookingData.address ?? "City",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Phone with icon
                                Row(
                                  children: const [
                                    Icon(Icons.phone,
                                        size: 18, color: Colors.grey),
                                    SizedBox(width: 6),
                                    Text("9876543210",
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  16.height,
                  Visibility(
                    visible: (bookingData.status ?? "").toLowerCase() ==
                            "ongoing" ||
                        (bookingData.status ?? "").toLowerCase() == "completed",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About Provider",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: Colors.transparent,
                          elevation: 3,
                          margin: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First row → Logo + Provider Info
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Provider Logo
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(
                                        bookingData.providerImage ?? "",
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Provider Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bookingData.providerName ??
                                                "Provider Name",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Car Washing Expert",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 8),

                                          // Ratings
                                          Row(
                                            children: [
                                              Row(
                                                children: List.generate(
                                                  5,
                                                  (index) => Icon(
                                                    Icons.star,
                                                    size: 18,
                                                    color: index <
                                                            (bookingData
                                                                    .totalRating
                                                                    ?.floor() ??
                                                                0)
                                                        ? Colors.orange
                                                        : Colors.grey.shade400,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "${bookingData.totalReview ?? "0.0"}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Second row → Call Button
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // implement call logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      textStyle: const TextStyle(fontSize: 14),
                                    ),
                                    icon: const Icon(Icons.call,
                                        size: 18, color: Colors.black),
                                    label: const Text(
                                      "Call",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  16.height,

                  const Text("Price Details",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  12.height,
                  // Price Details Card
                  Card(
                    color: Colors.transparent, // removes white background
                    elevation: 0, // removes shadow
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _buildRow("Preferences", "₹299"),
                          const Divider(thickness: 0.2, height: 16),
                          _buildRow("Addons", "₹499"),
                          const Divider(thickness: 0.2, height: 16),
                          _buildRow("Price", "₹120*1 = ₹120"),
                          const Divider(thickness: 0.2, height: 16),
                          _buildRow("Subtotal", "₹299"),
                          const Divider(thickness: 0.2, height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tax",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 16,
                                        color: context.primaryColor),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "₹49",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red, // 👈 red amount
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 0.2, height: 16),
                          _buildRow(
                            "Total Amount",
                            "₹299",
                            bold: true,
                            color: context.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  16.height,

                  // Payment Details (only for completed status)
                  Visibility(
                    visible:
                        (bookingData.status ?? "").toLowerCase() == "completed",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Id",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      "#${(bookingData.paymentId ?? 0).toString()}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const Divider(thickness: 0.2, height: 16),
                                // Payment Method
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Method",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      bookingData.paymentMethod ?? "N/A",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const Divider(thickness: 0.2, height: 16),

                                // Amount Paid
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Status",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      "Advance Paid",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green, // ✅ green color
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(thickness: 0.2, height: 16),

                                // Transaction ID
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Transaction ID",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      "pay_NhvrFJYptluHMG",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.red, // ✅ red color
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.height,

                  // Rate Now Section (only for completed status)
                  Visibility(
                    visible:
                        (bookingData.status ?? "").toLowerCase() == "completed",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                         Text(
                          "You Haven't rated yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: appStore.isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: context.primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: () {
    final TextEditingController reviewController = TextEditingController();
    int selectedRating = 0; // ⭐ store rating

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: appStore.isDarkMode ? Colors.white : Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.black,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Review",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 Body
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Your Rating:",
                          style: TextStyle(fontSize: 14, color: appStore.isDarkMode ? Colors.white : Colors.black),
                        ),
                        const SizedBox(height: 12),

                        // ⭐ Rating Row
                        Row(
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: context.primaryColor,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedRating = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 12),

                        // 🔹 Review TextField
                        TextField(
                          controller: reviewController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Your Review (Optional)",
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                        ),

                        const SizedBox(height: 20),

                        // 🔹 Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(color: Theme.of(context).primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  if (selectedRating == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please select a rating."),
                                      ),
                                    );
                                    return;
                                  }

                                  String review = reviewController.text.trim();
                                  // 👉 Handle rating + review logic
                                  Navigator.pop(context, {
                                    "rating": selectedRating,
                                    "review": review,
                                  });
                                },
                                child: const Text(
                                  "Next",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          },
        );
      },
    );
  },
  child: const Text(
    "Rate Now",
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
)

                        ),
                      ],
                    ),
                  ),
                  16.height,
                  // Your Review Card (only for completed status)
                  Visibility(
                    visible:
                        (bookingData.status ?? "").toLowerCase() == "completed",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Your Review",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      size: 20, color: Colors.grey),
                                  onPressed: () {
                                    // 👉 Edit logic
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20, color: Colors.grey),
                                  onPressed: () {
                                    // 👉 Delete logic
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.transparent,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: Logo + Name + Date + Rating
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        bookingData.providerImage ??
                                            "", // fallback image if null
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Name + Date
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bookingData.customerName ??
                                                "John Doe",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "September 2, 2025", // replace with formatted date
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // Row 2: Review Text
                                          Text(
                                            bookingData.description ??
                                                "This was a great service!",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Rating on right side
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 18, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text(
                                          bookingData.totalRating
                                                  ?.toStringAsFixed(1) ??
                                              "4.5",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  24.height,

                  // Cancel Button
                  Visibility(
  visible: (bookingData.status ?? "").toLowerCase() == "pending",
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: context.primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: () {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // disable outside tap
      barrierColor: appStore.isDarkMode ? Colors.white : Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cancel Booking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 🔹 Body
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   Text(
                      "Please give reason for cancelling this booking",
                      style: TextStyle(fontSize: 14, color: appStore.isDarkMode ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Reason TextField
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Specify your reason",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          String reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please specify a reason."),
                              ),
                            );
                            return;
                          }

                          // 👉 Handle cancel booking logic with reason
                          Navigator.pop(context, reason);
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  },
  child: const Text(
    "Cancel Booking",
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),
)

  ),
),

                ],
              ),
            ),
          ]),
        ));
  }

  Widget _vehicleCard(String vehicle, String name, String model, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171A1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vehicle : $vehicle",
                    style:  TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                Text("Bike name : $name",
                    style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                Text("Model : $model",
                    style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                Text("Price : $price",
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Right Edit Icon
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: appStore.isDarkMode ? Colors.white : Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: appStore.isDarkMode ? Colors.white : Colors.black, size: 16),
              onPressed: () {
                // TODO: Edit vehicle action
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _addonItem(String imagePath, String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171A1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// 🔹 Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedImageWidget(
              url: imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          /// 🔹 Title & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: appStore.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(price,
                    style:
                       TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black, fontSize: 13)),
              ],
            ),
          ),

          /// 🔹 Plus Button
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(),
            child: Icon(Icons.check_box_rounded,
                color: primaryColor, size: 20),
          ),
        ],
      ),
    );
  }
}

class BookingEvent {
  final String title;
  final String subtitle;
  final Color color;
  BookingEvent({required this.title, required this.subtitle, required this.color});
}

class BookingStatusRow extends StatelessWidget {
  final String time;
  final String date;
  final List<BookingEvent> events;

  const BookingStatusRow({
    Key? key,
    required this.time,
    required this.date,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Column 1: Time & Date
        SizedBox(
          width: 60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black, fontSize: 12)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // 🔹 Column 2: Timeline (dots & dotted line)
        Column(
          children: List.generate(events.length * 2 - 1, (index) {
            if (index.isEven) {
              int eventIndex = index ~/ 2;
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: events[eventIndex].color,
                  shape: BoxShape.circle,
                ),
              );
            } else {
              return Container(
                width: 2,
                height: 24,
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
                  ),
                ),
              );
            }
          }),
        ),

        const SizedBox(width: 16),

        // 🔹 Column 3: Event details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: events.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: TextStyle(color: e.color, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(e.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class TimelineEvent {
  final String time;
  final String date;
  final String title;
  final String subtitle;
  final Color color;

  TimelineEvent({
    required this.time,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}