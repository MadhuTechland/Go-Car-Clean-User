import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../auth/phone_entry_screen.dart';
import '../../jobRequest/my_post_request_list_screen.dart';

class NewJobRequestComponent extends StatelessWidget {
  const NewJobRequestComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(defaultRadius),
          topRight: Radius.circular(defaultRadius),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/img_new_post_job_1.png'),
          fit: BoxFit.cover,
        ),
      ),
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align to left
        children: [
          16.height,
          Text(
            language.jobRequestSubtitle,
            style: primaryTextStyle(color: Colors.black, size: 16, weight: FontWeight.bold), // ✅ Black text
            textAlign: TextAlign.left, // ✅ Left aligned
          ),
          20.height,
          AppButton(
            color: context.primaryColor, // ✅ Primary color background
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.black), // ✅ White icon
                4.width,
                Text(
                  language.newPostJobRequest,
                  style: boldTextStyle(color: Colors.black), // ✅ White text on button
                ),
              ],
            ),
            onTap: () async {
              if (appStore.isLoggedIn) {
                MyPostRequestListScreen().launch(context);
              } else {
                setStatusBarColor(Colors.black, statusBarIconBrightness: Brightness.dark);
                bool? res = await PhoneEntryScreen(returnExpected: true).launch(context);

                if (res ?? false) {
                  MyPostRequestListScreen().launch(context);
                }
              }
            },
          ),
          16.height,
        ],
      ),
    );
  }
}
