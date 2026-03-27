import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/service/service_book.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/colors.dart';

class ViewInstantWash extends StatefulWidget {
  const ViewInstantWash({super.key});

  @override
  State<ViewInstantWash> createState() => _ViewInstantWashState();
}

class _ViewInstantWashState extends State<ViewInstantWash> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 16, minute: 0);

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  int selectedWashWhere = 0;
  Set<int> selectedVehicleTypes = {}; // Add this at the top of your State class

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          appStore.isDarkMode ? const Color(0xFF0F1115) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Image
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: appStore.isDarkMode
                      ? Border.all(color: darkBorderGlow.withOpacity(0.5))
                      : null,
                  boxShadow: appStore.isDarkMode
                      ? [BoxShadow(color: primaryColor.withOpacity(0.08), blurRadius: 16)]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.network(
                        "https://stimg.cardekho.com/images/carexteriorimages/630x420/Mahindra/XUV-3XO/10184/1751288551835/front-left-side-47.jpg?imwidth=420&impolicy=resize",
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      if (appStore.isDarkMode)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  scaffoldColorDark.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("XUV300",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.black)),
                      const SizedBox(height: 4),
                      Text("XUV Plans",
                          style: TextStyle(
                              fontSize: 14,
                              color: appStore.isDarkMode
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.black54)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("SUV",
                        style: TextStyle(
                            color: appStore.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Plans
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
                        color: appStore.isDarkMode
                            ? darkSurface
                            : Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(12),
                        border: appStore.isDarkMode
                            ? Border.all(color: darkBorderGlow.withOpacity(0.5))
                            : null,
                        boxShadow: appStore.isDarkMode
                            ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 12)]
                            : null,
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
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                "₹99/WASH",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          /// Features List with ✅ icon
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              _featureItem("Interior Cleaning"),
                              _featureItem("Foam Wash"),
                              _featureItem("Wax Work"),
                              _featureItem("Tyre & Alloy Cleaning"),
                              _featureItem("Wax or Polish"),
                              _featureItem("Engine Bay Cleaning",
                                  included: false),
                            ],
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
                        color: appStore.isDarkMode
                            ? darkSurface
                            : Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(12),
                        border: appStore.isDarkMode
                            ? Border.all(color: darkBorderGlow.withOpacity(0.5))
                            : null,
                        boxShadow: appStore.isDarkMode
                            ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 12)]
                            : null,
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
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                "₹199/WASH",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
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
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// 🔹 Add more plans here...
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Addons
              Text("Addons",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          appStore.isDarkMode ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              _addonItem(model1_image, "AC Vent Cleaning", "₹100.00"),
              _addonItem(model2_image, "Leather Seat Conditioning", "₹100.00"),

              const SizedBox(height: 20),
              _bidPriceCard(),
              // Date & Slots
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
                  color: appStore.isDarkMode ? darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: appStore.isDarkMode
                      ? Border.all(color: darkBorderGlow.withOpacity(0.5))
                      : null,
                  boxShadow: appStore.isDarkMode
                      ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 12)]
                      : null,
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
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                                style: TextStyle(
                                    color: appStore.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14),
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
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                selectedTime.format(context),
                                style: TextStyle(
                                    color: appStore.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// 🔹 Right: Edit button
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: appStore.isDarkMode
                                ? darkBorderGlow
                                : Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit,
                            color: appStore.isDarkMode
                                ? primaryColor
                                : Colors.black,
                            size: 16),
                        onPressed: () {
                          // TODO: open date/time edit
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Choose wash place
              Text(
                "Choose Where To Wash Your Car",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
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
                          borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
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

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: appStore.isDarkMode ? darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: appStore.isDarkMode
                      ? Border.all(color: darkBorderGlow.withOpacity(0.5))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: appStore.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Our premium car wash service ensures your vehicle looks as good as new. "
                      "From interior cleaning to exterior polishing, every detail is handled "
                      "with care. Add extra services like AC vent cleaning or leather seat "
                      "conditioning for a complete experience.",
                      style: TextStyle(
                        color: appStore.isDarkMode ? Colors.white70 : Colors.black,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Gallery
              Text(
                "Gallery",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _galleryImg(car_image),
                    _galleryImg(bike_image),
                    _galleryImg(scooty_image),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 FAQs
              Text(
                "FAQs",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: appStore.isDarkMode
                            ? darkSurface
                            : Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(12),
                  border: appStore.isDarkMode
                      ? Border.all(color: darkBorderGlow.withOpacity(0.5))
                      : null,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor:
                        Colors.transparent, // removes expansion divider
                  ),
                  child: Column(
                    children: [
                      ExpansionTile(
                        iconColor: appStore.isDarkMode ? primaryColor : null,
                        collapsedIconColor: appStore.isDarkMode ? primaryColor : null,
                        title: Text(
                            "What services are included in the Basic Plan?",
                            style: TextStyle(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "The Basic Plan includes interior cleaning, foam wash, wax work, tyre & alloy cleaning, and more.",
                              style: TextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54),
                            ),
                          )
                        ],
                      ),
                      ExpansionTile(
                        iconColor: appStore.isDarkMode ? primaryColor : null,
                        collapsedIconColor: appStore.isDarkMode ? primaryColor : null,
                        title: Text("Do you offer doorstep service?",
                            style: TextStyle(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Yes, we provide car wash and detailing services at your doorstep for convenience.",
                              style: TextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54),
                            ),
                          )
                        ],
                      ),
                      ExpansionTile(
                        iconColor: appStore.isDarkMode ? primaryColor : null,
                        collapsedIconColor: appStore.isDarkMode ? primaryColor : null,
                        title: Text("Can I reschedule my booking?",
                            style: TextStyle(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Absolutely! You can reschedule your booking from the app at no extra cost.",
                              style: TextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.white70
                                      : Colors.black54),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reviews
              Text("Reviews",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          appStore.isDarkMode ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              _reviewItem("Donna Bins", "Quick, Clean, Super Convenient!",
                  "25 Aug 2025"),
              _reviewItem("Saul Armstrong",
                  "Affordable and Professional Service.", "26 Aug 2025"),

              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row Title + Button
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // allows multi-line text
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
                          maxLines: 3, // allows wrapping into 2–3 lines
                          overflow: TextOverflow.visible,
                        ),
                      ),

                      const SizedBox(width: 8),

                      /// Right Button
                      GestureDetector(
                        onTap: () {
                          Map<int, int> selectedBrandIndex = {};
                          Map<int, int?> selectedModelIndex =
                              {}; // key: vehicle type, value: selected brand index

// Define brand data for each type:
                          final bikeBrands = [
                            {
                              'img': bike_image,
                              'name': 'Bike',
                              'models': [
                                {'img': bike_image, 'name': 'Splendor'},
                                {'img': bike_image, 'name': 'Splendor Plus'},
                              ]
                            },
                            {
                              'img': scooty_image,
                              'name': 'Scooty',
                              'models': [
                                {'img': scooty_image, 'name': 'Scooty Pep'},
                                {'img': scooty_image, 'name': 'Scooty Streak'},
                              ]
                            },
                            {
                              'img': bike_image,
                              'name': 'Yamaha',
                              'models': [
                                {'img': bike_image, 'name': 'FZ'},
                                {'img': bike_image, 'name': 'R15'},
                              ]
                            },
                          ];

                          final carBrands = [
                            {
                              'img': car_image,
                              'name': 'Car',
                              'models': [
                                {'img': car_image, 'name': 'Swift'},
                                {'img': car_image, 'name': 'Baleno'},
                              ]
                            },
                            {
                              'img': car_xuv300,
                              'name': 'XUV300',
                              'models': [
                                {'img': car_xuv300, 'name': 'Base'},
                                {'img': car_xuv300, 'name': 'Sport'},
                              ]
                            },
                            {
                              'img': car_xuv400,
                              'name': 'XUV400',
                              'models': [
                                {'img': car_xuv400, 'name': 'EV'},
                              ]
                            },
                          ];
                          final busBrands = [
                            {
                              'img': bus_image,
                              'name': 'Bus',
                              'models': [
                                {'img': bus_image, 'name': 'Tata'},
                                {'img': bus_image, 'name': 'Ashok Leyland'},
                              ]
                            },
                            {
                              'img': bus_image,
                              'name': 'Volvo',
                              'models': [
                                {'img': bus_image, 'name': '9400'},
                                {'img': bus_image, 'name': '9600'},
                              ]
                            },
                            {
                              'img': bus_image,
                              'name': 'Mini Bus',
                              'models': [
                                {'img': bus_image, 'name': 'Mini Bus'},
                              ]
                            },
                          ];

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: appStore.isDarkMode
                            ? scaffoldColorDark
                            : Color(0xFFE0E0E0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (BuildContext modalContext) {
                              return StatefulBuilder(
                                builder: (modalContext, setModalState) {
                                  return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8, // ⬅️ 80% height
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 80, // width of the bar
                                                height:
                                                    6, // thickness of the bar
                                                margin: EdgeInsets.only(
                                                    bottom:
                                                        16), // spacing below the bar
                                                decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // rounded edges
                                                ),
                                              ),
                                              Text(
                                                "Which Type of Vehicle Do you Have?",
                                                style: TextStyle(
                                                  color: appStore.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  // Bike
                                                  GestureDetector(
                                                    onTap: () {
                                                      setModalState(() {
                                                        if (selectedVehicleTypes
                                                            .contains(0)) {
                                                          selectedVehicleTypes
                                                              .remove(0);
                                                        } else {
                                                          selectedVehicleTypes
                                                              .add(0);
                                                        }
                                                      });
                                                    },
                                                    child: Row(
                                                      children: [
                                                        CachedImageWidget(url: bike_image,
                                                            width: 32,
                                                            height: 32),
                                                        SizedBox(width: 6),
                                                        Text("Bike",
                                                            style: TextStyle(
                                                                color: appStore
                                                                        .isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        if (selectedVehicleTypes
                                                            .contains(0))
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 4),
                                                            child: Icon(
                                                                Icons.check,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                size: 18),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Car
                                                  GestureDetector(
                                                    onTap: () {
                                                      setModalState(() {
                                                        if (selectedVehicleTypes
                                                            .contains(1)) {
                                                          selectedVehicleTypes
                                                              .remove(1);
                                                        } else {
                                                          selectedVehicleTypes
                                                              .add(1);
                                                        }
                                                      });
                                                    },
                                                    child: Row(
                                                      children: [
                                                        CachedImageWidget(url: car_image,
                                                            width: 32,
                                                            height: 32),
                                                        SizedBox(width: 6),
                                                        Text("Car",
                                                            style: TextStyle(
                                                                color: appStore
                                                                        .isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        if (selectedVehicleTypes
                                                            .contains(1))
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 4),
                                                            child: Icon(
                                                                Icons.check,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                size: 18),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Bus
                                                  GestureDetector(
                                                    onTap: () {
                                                      setModalState(() {
                                                        if (selectedVehicleTypes
                                                            .contains(2)) {
                                                          selectedVehicleTypes
                                                              .remove(2);
                                                        } else {
                                                          selectedVehicleTypes
                                                              .add(2);
                                                        }
                                                      });
                                                    },
                                                    child: Row(
                                                      children: [
                                                        CachedImageWidget(url: bus_image,
                                                            width: 32,
                                                            height: 32),
                                                        SizedBox(width: 6),
                                                        Text("Bus",
                                                            style: TextStyle(
                                                                color: appStore
                                                                        .isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        if (selectedVehicleTypes
                                                            .contains(2))
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 4),
                                                            child: Icon(
                                                                Icons.check,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                size: 18),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Add these maps at the top of your State class to track selected brands:

                                              if (selectedVehicleTypes
                                                  .isNotEmpty) ...[
                                                SizedBox(height: 18),
                                                Text("Choose your brand",
                                                    style: TextStyle(
                                                        color:
                                                            appStore.isDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16)),
                                                SizedBox(height: 12),

                                                // Render all brand rows first
                                                for (var type
                                                    in selectedVehicleTypes) ...[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          type == 0
                                                              ? "Bike"
                                                              : type == 1
                                                                  ? "Car"
                                                                  : "Bus",
                                                          style: TextStyle(
                                                              color: appStore
                                                                      .isDarkMode
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15),
                                                        ),
                                                        SizedBox(height: 8),

                                                        // Brand Selection
                                                        SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            children: [
                                                              for (int i = 0;
                                                                  i <
                                                                      (type == 0
                                                                          ? bikeBrands
                                                                              .length
                                                                          : type == 1
                                                                              ? carBrands.length
                                                                              : busBrands.length);
                                                                  i++) ...[
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setModalState(
                                                                        () {
                                                                      selectedBrandIndex[
                                                                          type] = i;
                                                                      selectedModelIndex[
                                                                              type] =
                                                                          null; // Reset model when brand changes
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        right:
                                                                            12),
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(6),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: selectedBrandIndex[type] ==
                                                                                i
                                                                            ? Theme.of(context).primaryColor
                                                                            : Colors.transparent,
                                                                        width:
                                                                            2,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        CachedImageWidget(
                                                                          url: (type == 0
                                                                              ? bikeBrands[i]['img']
                                                                              : type == 1
                                                                                  ? carBrands[i]['img']
                                                                                  : busBrands[i]['img']) as String,
                                                                          width:
                                                                              48,
                                                                          height:
                                                                              48,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                6),
                                                                        Text(
                                                                          (type == 0
                                                                              ? bikeBrands[i]['name']
                                                                              : type == 1
                                                                                  ? carBrands[i]['name']
                                                                                  : busBrands[i]['name']) as String,
                                                                          style: TextStyle(
                                                                              color: appStore.isDarkMode ? Colors.white : Colors.black,
                                                                              fontSize: 13),
                                                                        ),
                                                                        if (selectedBrandIndex[type] ==
                                                                            i)
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 4),
                                                                            child: Icon(Icons.check,
                                                                                color: Theme.of(context).primaryColor,
                                                                                size: 16),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],

                                                // Pick your model section AFTER all brand sections
                                                if (selectedBrandIndex.values
                                                    .any((v) => v != null)) ...[
                                                  SizedBox(height: 16),
                                                  Text(
                                                    "Pick your model below",
                                                    style: TextStyle(
                                                        color:
                                                            appStore.isDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    textAlign: TextAlign
                                                        .start, // ⬅️ ensures text is left aligned
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Show models for ALL selected types + brands
                                                  for (var entry
                                                      in selectedBrandIndex
                                                          .entries
                                                          .where((e) =>
                                                              e.value !=
                                                              null)) ...[
                                                    SizedBox(height: 12),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        entry.key == 0
                                                            ? "Bike Models"
                                                            : entry.key == 1
                                                                ? "Car Models"
                                                                : "Bus Models",
                                                        style: TextStyle(
                                                            color: appStore
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Builder(builder: (_) {
                                                      final type = entry.key;
                                                      final brandIndex =
                                                          entry.value!;
                                                      final models = (type == 0
                                                          ? bikeBrands[
                                                                  brandIndex]
                                                              ['models']
                                                          : type == 1
                                                              ? carBrands[
                                                                      brandIndex]
                                                                  ['models']
                                                              : busBrands[
                                                                      brandIndex]
                                                                  [
                                                                  'models']) as List;

                                                      return SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          children: [
                                                            for (int j = 0;
                                                                j <
                                                                    models
                                                                        .length;
                                                                j++) ...[
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setModalState(
                                                                      () {
                                                                    selectedModelIndex[
                                                                        type] = j;
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              12),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: selectedModelIndex[type] == j
                                                                          ? Theme.of(context)
                                                                              .primaryColor
                                                                          : Colors
                                                                              .transparent,
                                                                      width: 2,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      CachedImageWidget(
                                                                          url: models[j]['img']
                                                                              as String,
                                                                          width:
                                                                              48,
                                                                          height:
                                                                              48),
                                                                      SizedBox(
                                                                          width:
                                                                              6),
                                                                      Text(
                                                                          models[j]['name']
                                                                              as String,
                                                                          style: TextStyle(
                                                                              color: appStore.isDarkMode ? Colors.white : Colors.black,
                                                                              fontSize: 13)),
                                                                      if (selectedModelIndex[
                                                                              type] ==
                                                                          j)
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 4),
                                                                          child: Icon(
                                                                              Icons.check,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: 16),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                                  ],

// ⬇️ AFTER all model sections, render plans
                                                  if (selectedModelIndex.values
                                                      .any((v) =>
                                                          v != null)) ...[
                                                    SizedBox(height: 20),
                                                    Text("Available Plans",
                                                        style: TextStyle(
                                                            color: appStore
                                                                    .isDarkMode
                                                                ? Colors.white
                                                                : Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16)),
                                                    SizedBox(height: 12),
                                                    for (var entry
                                                        in selectedModelIndex
                                                            .entries
                                                            .where((e) =>
                                                                e.value !=
                                                                null)) ...[
                                                      Builder(builder: (_) {
                                                        final type = entry.key;
                                                        final brandIndex =
                                                            selectedBrandIndex[
                                                                type]!;
                                                        final modelIndex =
                                                            entry.value!;
                                                        final models = (type ==
                                                                0
                                                            ? bikeBrands[
                                                                    brandIndex]
                                                                ['models']
                                                            : type == 1
                                                                ? carBrands[
                                                                        brandIndex]
                                                                    ['models']
                                                                : busBrands[
                                                                        brandIndex]
                                                                    [
                                                                    'models']) as List;

                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            _plansForModel(
                                                                models[modelIndex]
                                                                        ['name']
                                                                    as String,
                                                                type),
                                                            SizedBox(
                                                                height: 16),
                                                          ],
                                                        );
                                                      }),
                                                    ],
                                                  ]
                                                ]
                                              ],
                                              Container(
                                                decoration: appStore.isDarkMode
                                                    ? BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),
                                                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 16)],
                                                      )
                                                    : null,
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          primaryColor,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 14),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12))),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ServiceBookScreen(),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Confirm",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ));
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: appStore.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  size: 16),
                              SizedBox(width: 6),
                              Text(
                                "Add Extra Vehicles",
                                style: TextStyle(
                                    color: appStore.isDarkMode
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Vehicle Cards (example 2 cards)
                  Column(
                    children: [
                      _vehicleCard("Bike", "---", "---", "₹200"),
                      _vehicleCard("Car", "Swift", "VXI", "₹400"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Personal Details
              Text("Personal Details",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          appStore.isDarkMode ? Colors.white : Colors.black)),
              const SizedBox(height: 10),
              _inputField("Enter name", nameCtrl),
              const SizedBox(height: 10),
              _inputField("Enter mobile number", phoneCtrl),

              const SizedBox(height: 20),
              Container(
                decoration: appStore.isDarkMode
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 16)],
                      )
                    : null,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ServiceBookScreen(),
                      ),
                    );
                  },
                  child: const Text("Book Now",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _plansForModel(String modelName, int type) {
    // You can customize per model or per type
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        /// Title
        Text(
          type == 0
              ? "$modelName Plans" // Bike
              : type == 1
                  ? "$modelName Plans" // Car
                  : "$modelName Plans", // Bus
          style: TextStyle(
            color: appStore.isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        /// Scrollable plans list
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _planCard("BASIC PLAN", "₹99/WASH", [
                "Interior Cleaning",
                "Foam Wash",
                "Wax Work",
                "Tyre & Alloy Cleaning",
                "Wax or Polish",
              ]),
              const SizedBox(width: 12),
              _planCard("SHINE PLAN", "₹199/WASH", [
                "Exterior Body Wash",
                "Light Interior Cleaning",
                "Foam Wash",
                "Tyre & Alloy Clean",
              ]),
              // you can add more plan cards...
            ],
          ),
        ),
      ],
    );
  }

  Widget _planCard(String title, String price, List<String> features) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkMode
                            ? darkSurface
                            : Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
        border: appStore.isDarkMode
            ? Border.all(color: darkBorderGlow.withOpacity(0.5))
            : null,
        boxShadow: appStore.isDarkMode
            ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 12)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          appStore.isDarkMode ? Colors.white : Colors.black)),
              Text(price,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          appStore.isDarkMode ? Colors.white : Colors.black)),
            ],
          ),
          const SizedBox(height: 10),

          /// Features
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var f in features)
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(f,
                        style: TextStyle(
                            color: appStore.isDarkMode
                                ? Colors.white
                                : Colors.black)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: appStore.isDarkMode
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 12)],
                  )
                : null,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
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
        color: appStore.isDarkMode
                            ? darkSurface
                            : Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
        border: appStore.isDarkMode
            ? Border.all(color: darkBorderGlow.withOpacity(0.4))
            : null,
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
              color: appStore.isDarkMode ? primaryColor : null,
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
                        color:
                            appStore.isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(price,
                    style: TextStyle(
                        color:
                            appStore.isDarkMode ? Colors.white70 : Colors.black,
                        fontSize: 13)),
              ],
            ),
          ),

          /// 🔹 Plus Button
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(
                  color: appStore.isDarkMode ? darkBorderGlow : Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add,
                color: appStore.isDarkMode ? primaryColor : Colors.black,
                size: 18),
          ),
        ],
      ),
    );
  }

  Widget _bidPriceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: appStore.isDarkMode
            ? LinearGradient(
                colors: [quickActionCardBg, darkSurface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: appStore.isDarkMode ? null : Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
        border: appStore.isDarkMode
            ? Border.all(color: darkBorderGlow.withOpacity(0.5))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 🔹 Left Text
          Expanded(
            child: Text(
              "Bid your price, get the best wash!",
              style: TextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// 🔹 Button with + icon
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // TODO: open bid price flow
            },
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              "Bid Price",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeOption(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkMode ? darkSurface : Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
        border: appStore.isDarkMode
            ? Border.all(color: darkBorderGlow.withOpacity(0.5))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 6),
          Text(text,
              style: TextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black))
        ],
      ),
    );
  }

  Widget _galleryImg(String imagePath) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: appStore.isDarkMode
            ? Border.all(color: darkBorderGlow.withOpacity(0.3))
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedImageWidget(
          url: imagePath,
          width: 120,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _reviewItem(String name, String review, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkMode
                            ? darkSurface
                            : Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
        border: appStore.isDarkMode
            ? Border.all(color: darkBorderGlow.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: NetworkImage(
              "https://randomuser.me/api/portraits/women/44.jpg",
            ),
          ),
          const SizedBox(width: 10),

          /// 🔹 Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),

                /// Date
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: appStore.isDarkMode ? Colors.white60 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 6),

                /// Review
                Text(
                  review,
                  style: TextStyle(
                      color: appStore.isDarkMode ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),

          /// 🔹 Rating
          Icon(Icons.star, color: ratingBarColor, size: 18),
          Text(" 4.5",
              style: TextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  Widget _vehicleCard(String vehicle, String name, String model, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appStore.isDarkMode ? darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: appStore.isDarkMode
            ? Border.all(color: darkBorderGlow.withOpacity(0.5))
            : null,
        boxShadow: appStore.isDarkMode
            ? [BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 12)]
            : null,
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
                    style: TextStyle(
                        color:
                            appStore.isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                Text("Bike name : $name",
                    style: TextStyle(
                        color:
                            appStore.isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                Text("Model : $model",
                    style: TextStyle(
                        color:
                            appStore.isDarkMode ? Colors.white : Colors.black)),
                const SizedBox(height: 6),
                Text("Price : $price",
                    style: TextStyle(
                        color: appStore.isDarkMode ? primaryColor : Colors.green,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Right Edit Icon
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: appStore.isDarkMode ? darkBorderGlow : Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.edit,
                  color: appStore.isDarkMode ? primaryColor : Colors.black,
                  size: 16),
              onPressed: () {
                // TODO: Edit vehicle action
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style:
          TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: appStore.isDarkMode
                            ? greetingTextColor
                            : Colors.black),
        filled: true,
        fillColor: appStore.isDarkMode
                            ? darkSurface
                            : Color(0xFFE0E0E0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: appStore.isDarkMode ? primaryColor : Colors.black,
                width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: appStore.isDarkMode
                ? BorderSide(color: darkBorderGlow.withOpacity(0.3))
                : BorderSide.none),
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
              style: TextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
