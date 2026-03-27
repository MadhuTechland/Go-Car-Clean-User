import 'package:flutter/material.dart';
import '../../../../utils/colors.dart';
import '../../../service/instant_wash.dart';

class WashTypeBottomSheet {
  static void show(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // ✅ Keep state outside of builder
        String selectedType = "instant";

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Wash Type",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 🔹 Instant Wash
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedType = "instant";
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedType == "instant"
                                  ? const Color(0xFFE0E7FF)
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedType == "instant"
                                    ? primaryColor
                                    : Colors.grey.shade700,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.asset(
                                    'assets/images/instant.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Instant Wash",
                                  style: TextStyle(
                                    color: selectedType == "instant"
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: width * 0.03,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 🔹 Daily Wash
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedType = "daily";
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedType == "daily"
                                  ? const Color(0xFFE0E7FF)
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedType == "daily"
                                    ? primaryColor
                                    : Colors.grey.shade700,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.asset(
                                    'assets/images/daily.png',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Daily Wash",
                                  style: TextStyle(
                                    color: selectedType == "daily"
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: width * 0.03,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (selectedType == "instant") {
                          Navigator.pop(context); // close bottomsheet first
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InstantWashScreen(),
                            ),
                          );
                        } else if (selectedType == "daily") {
                          Navigator.pop(context); // just close the popup
                        }
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
