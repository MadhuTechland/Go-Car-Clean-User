import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceBookScreen extends StatelessWidget {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 16, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Instant Car Wash"),
        backgroundColor: context.primaryColor,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: appStore.isDarkMode ? Colors.black : Colors.white)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SUV',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor)),
                      Text('XUV300', style: TextStyle(fontSize: 18, color: appStore.isDarkMode ? Colors.white : Colors.black)),
                      SizedBox(height: 8),
                      Text('Car Wash', style: TextStyle(fontSize: 14, color: appStore.isDarkMode ? Colors.white70 : Colors.black54)),
                    ],
                  ),
                  Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImageWidget(
                      url: car_xuv300,
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('Your Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: appStore.isDarkMode ? Colors.white : Colors.black)),
            12.height,
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appStore.isDarkMode ? Colors.black : Colors.white, // or use a dark color like Color(0xFF171A1F)
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: appStore.isDarkMode ? Colors.black26 : Colors.white24), // optional: add border
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your address',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Implement choose from map
                  },
                  child: Text(
                    'Choose from Map',
                    style: TextStyle(color: context.primaryColor),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Implement use current location
                  },
                  child: Text(
                    'Use Current Location',
                    style: TextStyle(color: context.primaryColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Description',
              style: TextStyle(
                  fontFamily: 'Bold',
                  fontWeight: FontWeight.bold,
                  fontSize: 16, color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text('XUV Plans',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: appStore.isDarkMode ? Colors.white : Colors.black)),
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('View All', style: TextStyle(color: context.primaryColor)),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  /// 🔹 BASIC PLAN
                  Container(
                    width: 220, // fixed width for each plan card
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appStore.isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title & Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "BASIC PLAN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: appStore.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              "₹99/WASH",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: appStore.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        /// Features List with ✅ icon
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _featureItem("Interior Cleaning"),
                            _featureItem("Foam Wash"),
                            _featureItem("Wax Work"),
                            _featureItem("Tyre & Alloy Cleaning"),
                            _featureItem("Wax or Polish"),
                            _featureItem("Engine Bay Cleaning",
                                included: false),
                          ],
                        ),
                        const SizedBox(height: 16),

                        /// Button after features
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // TODO: Handle Basic Plan selection
                            },
                            child: Text(
                              "Basic Plan ₹99",
                              style: TextStyle(
                                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// 🔹 SHINE PLAN
                  Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appStore.isDarkMode ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title & Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "SHINE PLAN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: appStore.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              "₹199/WASH",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: appStore.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        /// Features List with ✅ icon
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _featureItem("Exterior Body Wash"),
                            _featureItem("Light Interior Cleaning"),
                            _featureItem("Form Wash"),
                            _featureItem("Tyre & Alloy Clean"),
                            _featureItem("Steam Or Engine", included: false),
                            _featureItem("Wax or Polish", included: false),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // TODO: Handle Basic Plan selection
                            },
                            child: Text(
                              "Shine Plan ₹199",
                              style: TextStyle(
                                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// 🔹 Add more plans here...
                ],
              ),
            ),
             Text("Addons",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: appStore.isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 10),
            _addonItem(model1_image, "AC Vent Cleaning", "₹100.00"),
            _addonItem(model2_image, "Leather Seat Conditioning", "₹100.00"),
            SizedBox(height: 12),
            Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: [
                _vehicleCard("Bike", "---", "---", "₹200"),
                _vehicleCard("Car", "Swift", "VXI", "₹400"),
              ],
            ),
            SizedBox(height: 12),
             Text(
              "Booking Date And Slots",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: appStore.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appStore.isDarkMode
                            ? Color(0xFF171A1F)
                            : Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Left: Date & Time in Column (each as a Row)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Date row
                        Row(
                          children: [
                             Text(
                              "Date : ",
                              style: TextStyle(
                                color: appStore.isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                              style: TextStyle(
                                  color: appStore.isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Time row
                        Row(
                          children: [
                             Text(
                              "Time : ",
                              style: TextStyle(
                                color: appStore.isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              selectedTime.format(context),
                              style: TextStyle(
                                  color: appStore.isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// 🔹 Right: Edit button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: appStore.isDarkMode ? Colors.white24 : Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon:
                           Icon(Icons.edit, color: appStore.isDarkMode ? Colors.white : Colors.black, size: 16),
                      onPressed: () {
                        // TODO: open date/time edit
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('Location Type',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appStore.isDarkMode
                            ? Color(0xFF171A1F)
                            : Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
                // border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Text(
                    'Location Type: At home',
                    style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit, color: appStore.isDarkMode ? Colors.white : Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('Personal Details',
                style: TextStyle(fontWeight: FontWeight.bold, color: appStore.isDarkMode ? Colors.white : Colors.black)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appStore.isDarkMode
                            ? Color(0xFF171A1F)
                            : Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appStore.isDarkMode ? Colors.white24 : Colors.black26),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Details Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Name',
                                style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
                            Spacer(),
                            Text('Saiprakash',
                                style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text('Mobile Number',
                                style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
                            Spacer(),
                            Text('8431148811',
                                style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Edit Button
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: appStore.isDarkMode ? Colors.white24 : Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: appStore.isDarkMode ? Colors.white : Colors.black, size: 18),
                      onPressed: () {
                        // TODO: Handle edit action
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.card_giftcard,
                    color: context.primaryColor, size: 20),
                SizedBox(width: 8),
                Text('Coupons', style: TextStyle(fontWeight: FontWeight.bold, color: appStore.isDarkMode ? Colors.white : Colors.black)),
                Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('Apply Coupons',
                      style: TextStyle(color: context.primaryColor)),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Price Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _priceRow('Price', '₹120 x 1 = 120'),
                  _priceRow('Addons', '₹100'),
                  _priceRow('Subtotal', '₹600'),
                  _priceRow('Discount', '-₹50', discountText: '5% off'),
                  _priceRow('Tax', '₹30', showTaxIcon: true),
                  _priceRow('Coupon', '-₹20', couponCode: 'A3edfried'),
                  _priceRow('Total Amount', '₹560',
                      isBold: true, isTotal: true),
                ],
              ),
            ),
            SizedBox(height: 8),
            _priceRow('Price', '₹120 x 1 = ₹120'),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () {},
                child: const Text("Confirm",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You will be asked for payment once your booking is completed.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleCard(String vehicle, String name, String model, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkMode
                            ? Color(0xFF171A1F)
                            : Color(0xFFE0E0E0),
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
                    style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black)),
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
              border: Border.all(color: appStore.isDarkMode ? Colors.white24 : Colors.black26),
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

  Widget _priceRow(
    String label,
    String value, {
    bool isBold = false,
    String? discountText,
    bool showTaxIcon = false,
    String? couponCode,
    bool isTotal = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (discountText != null) ...[
                    SizedBox(width: 6),
                    Text(
                      '($discountText)',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (couponCode != null) ...[
                    SizedBox(width: 6),
                    Text(
                      '($couponCode)',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
              Spacer(),
              if (showTaxIcon) ...[
                Container(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.error_outline, color: Colors.red, size: 16),
                ),
              ],
              Text(
                value,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: discountText != null
                      ? Colors.green
                      : showTaxIcon
                          ? Colors.red
                          : couponCode != null
                              ? Colors.green
                              : isTotal
                                  ? primaryColor
                                  : null,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.white24,
          thickness: 0.5,
          height: 8,
        ),
      ],
    );
  }

  Widget _addonItem(String imagePath, String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkMode
                            ? Color(0xFF171A1F)
                            : Color(0xFFE0E0E0),
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

class _featureItem extends StatelessWidget {
  final String text;
  final bool included; // true = ✅, false = ❌

  const _featureItem(this.text, {this.included = true, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel, // ✅ or ❌
            color: included ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
