import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/firebase_messaging_utils.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'auth/change_password_screen.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Widget _buildSettingItem({
    required String icon,
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final bool isDark = appStore.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon.iconImage(size: 18, color: primaryColor),
            ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: primaryTextStyle(size: 14)),
                if (subtitle != null) ...[
                  2.height,
                  Text(subtitle, style: secondaryTextStyle(size: 12)),
                ],
              ],
            ).expand(),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({required bool value, required ValueChanged<bool> onChanged}) {
    return Transform.scale(
      scale: 0.8,
      child: Switch.adaptive(
        value: value,
        activeTrackColor: primaryColor,
        activeThumbColor: Colors.white,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = appStore.isDarkMode;

    return AppScaffold(
      appBarTitle: language.lblAppSetting,
      child: AnimatedScrollView(
        padding: EdgeInsets.all(16),
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? darkSurfaceVariant : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: darkBorderGlow, width: 1) : null,
              boxShadow: isDark
                  ? []
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                if (isLoginTypeUser)
                  _buildSettingItem(
                    icon: ic_lock,
                    title: language.changePassword,
                    isFirst: true,
                    trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.grey.shade400, size: 20),
                    onTap: () => doIfLoggedIn(context, () => ChangePasswordScreen().launch(context)),
                  ),
                _buildSettingItem(
                  icon: ic_slider_status,
                  title: language.lblAutoSliderStatus,
                  subtitle: 'Auto-scroll banner images',
                  trailing: _buildSwitch(
                    value: getBoolAsync(AUTO_SLIDER_STATUS, defaultValue: true),
                    onChanged: (v) {
                      setValue(AUTO_SLIDER_STATUS, v);
                      setState(() {});
                    },
                  ),
                ),
                _buildSettingItem(
                  icon: ic_check_update,
                  title: language.lblOptionalUpdateNotify,
                  subtitle: 'Get notified about updates',
                  trailing: _buildSwitch(
                    value: getBoolAsync(UPDATE_NOTIFY, defaultValue: true),
                    onChanged: (v) {
                      setValue(UPDATE_NOTIFY, v);
                      setState(() {});
                    },
                  ),
                ),
                if (appStore.isLoggedIn)
                  _buildSettingItem(
                    icon: ic_notification,
                    title: language.pushNotification,
                    subtitle: 'Receive push notifications',
                    trailing: Observer(builder: (context) {
                      return _buildSwitch(
                        value: FirebaseAuth.instance.currentUser != null && appStore.isSubscribedForPushNotification,
                        onChanged: (v) async {
                          if (appStore.isLoading) return;
                          appStore.setLoading(true);
                          if (v) {
                            await subscribeToFirebaseTopic();
                          } else {
                            await unsubscribeFirebaseTopic(appStore.userId);
                          }
                          appStore.setLoading(false);
                          setState(() {});
                        },
                      );
                    }),
                  ),
                SnapHelperWidget<bool>(
                  future: isAndroid12Above(),
                  onSuccess: (data) {
                    if (data) {
                      return _buildSettingItem(
                        icon: ic_android_12,
                        title: language.lblMaterialTheme,
                        subtitle: 'Use system dynamic colors',
                        isLast: true,
                        trailing: _buildSwitch(
                          value: appStore.useMaterialYouTheme,
                          onChanged: (v) {
                            showConfirmDialogCustom(
                              context,
                              onAccept: (_) {
                                appStore.setUseMaterialYouTheme(v.validate());
                                RestartAppWidget.init(context);
                              },
                              title: language.lblAndroid12Support,
                              primaryColor: context.primaryColor,
                              positiveText: language.lblYes,
                              negativeText: language.lblCancel,
                            );
                          },
                        ),
                      );
                    }
                    return Offstage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
