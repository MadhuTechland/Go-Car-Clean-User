import 'package:booking_system_flutter/component/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CategoryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      physics: AlwaysScrollableScrollPhysics(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        itemCount: 6,
        itemBuilder: (_, index) {
          return ShimmerWidget(
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 90,
                    height: 14,
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
                  ),
                  8.height,
                  Container(
                    width: 110,
                    height: 10,
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
