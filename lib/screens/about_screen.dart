import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_configuration.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget _buildContactCard({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final bool isDark = appStore.isDarkMode;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
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
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(icon, height: 22, color: primaryColor),
              ),
              10.height,
              Text(label, style: primaryTextStyle(size: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    final bool isDark = appStore.isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? darkSurfaceVariant : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: darkBorderGlow, width: 1) : Border.all(color: Colors.grey.shade200),
        ),
        child: Image.asset(icon, height: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = appStore.isDarkMode;

    return AppScaffold(
      appBarTitle: language.about,
      child: AnimatedScrollView(
        crossAxisAlignment: CrossAxisAlignment.center,
        listAnimationType: ListAnimationType.FadeIn,
        padding: EdgeInsets.all(16),
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          // Logo + App info card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? darkSurfaceVariant : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? Border.all(color: darkBorderGlow, width: 1) : null,
              boxShadow: isDark
                  ? []
                  : [BoxShadow(color: primaryColor.withValues(alpha: 0.06), blurRadius: 20, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(appLogo, height: 60),
                ),
                16.height,
                Text(APP_NAME, style: boldTextStyle(size: 20)),
                8.height,
                Text(
                  APP_NAME_TAG_LINE,
                  style: secondaryTextStyle(size: 13),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                16.height,
                SnapHelperWidget<PackageInfoData>(
                  future: getPackageInfo(),
                  onSuccess: (data) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v${data.versionName}',
                        style: secondaryTextStyle(size: 12, color: primaryColor),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          20.height,
          // Contact cards
          Row(
            children: [
              if (appConfigurationStore.helplineNumber.isNotEmpty)
                _buildContactCard(
                  context: context,
                  icon: ic_calling,
                  label: language.lblCall,
                  onTap: () {
                    toast(appConfigurationStore.helplineNumber);
                    launchCall(appConfigurationStore.helplineNumber);
                  },
                ),
              if (appConfigurationStore.helplineNumber.isNotEmpty && appConfigurationStore.inquiryEmail.isNotEmpty)
                16.width,
              if (appConfigurationStore.inquiryEmail.isNotEmpty)
                _buildContactCard(
                  context: context,
                  icon: ic_message,
                  label: language.email,
                  onTap: () => launchMail(appConfigurationStore.inquiryEmail),
                ),
            ],
          ),
          20.height,
          // Description
          if (getStringAsync(SITE_DESCRIPTION).isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? darkSurfaceVariant : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isDark ? Border.all(color: darkBorderGlow, width: 1) : null,
                boxShadow: isDark
                    ? []
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 2))],
              ),
              child: Text(
                parseHtmlString(getStringAsync(SITE_DESCRIPTION)),
                style: primaryTextStyle(size: 14, color: isDark ? Colors.white70 : Colors.grey.shade700),
                textAlign: TextAlign.justify,
              ),
            ),
          20.height,
          // Social links
          Builder(builder: (context) {
            final socialLinks = <MapEntry<String, String>>[];
            if (getStringAsync(FACEBOOK_URL).isNotEmpty) socialLinks.add(MapEntry(ic_facebook, getStringAsync(FACEBOOK_URL)));
            if (getStringAsync(INSTAGRAM_URL).isNotEmpty) socialLinks.add(MapEntry(ic_instagram, getStringAsync(INSTAGRAM_URL)));
            if (getStringAsync(TWITTER_URL).isNotEmpty) socialLinks.add(MapEntry(ic_twitter, getStringAsync(TWITTER_URL)));
            if (getStringAsync(LINKEDIN_URL).isNotEmpty) socialLinks.add(MapEntry(ic_linkedIN, getStringAsync(LINKEDIN_URL)));
            if (getStringAsync(YOUTUBE_URL).isNotEmpty) socialLinks.add(MapEntry(ic_youtube, getStringAsync(YOUTUBE_URL)));

            if (socialLinks.isEmpty) return SizedBox();

            return Column(
              children: [
                Text('Follow Us', style: boldTextStyle(size: 14, color: isDark ? Colors.white70 : Colors.grey.shade600)),
                16.height,
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: socialLinks.map((entry) {
                    return _buildSocialButton(
                      icon: entry.key,
                      onTap: () => commonLaunchUrl(entry.value, launchMode: LaunchMode.externalApplication),
                    );
                  }).toList(),
                ),
              ],
            );
          }),
          30.height,
        ],
      ),
    );
  }
}
