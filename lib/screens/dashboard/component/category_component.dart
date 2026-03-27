import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/screens/category/category_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_widget.dart';
import 'package:booking_system_flutter/screens/service/view_all_service_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData>? categoryList;
  final bool isNewDashboard;

  CategoryComponent({this.categoryList, this.isNewDashboard = false});

  @override
  CategoryComponentState createState() => CategoryComponentState();
}

class CategoryComponentState extends State<CategoryComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categoryList.validate().isEmpty) return Offstage();

    final categories = widget.categoryList!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Vehicle',
                    style: boldTextStyle(size: 16),
                  ),
                  4.height,
                  Text(
                    'Select vehicle type to explore services',
                    style: secondaryTextStyle(size: 12),
                  ),
                ],
              ).expand(),
              if (categories.length >= 4)
                TextButton(
                  onPressed: () {
                    CategoryScreen().launch(context).then((value) {
                      setStatusBarColor(Colors.transparent);
                    });
                  },
                  child: Text(language.lblViewAll, style: boldTextStyle(size: 12, color: primaryColor)),
                ),
            ],
          ),
        ),
        12.height,
        // Horizontal scrollable vehicle cards
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => 12.width,
            itemBuilder: (context, i) {
              CategoryData data = categories[i];
              return GestureDetector(
                onTap: () {
                  ViewAllServiceScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
                },
                child: CategoryWidget(categoryData: data, width: 90),
              );
            },
          ),
        ),
        16.height,
      ],
    );
  }
}
