import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/about_screen.dart';
import 'package:booking_system_flutter/screens/auth/edit_profile_screen.dart';
import 'package:booking_system_flutter/screens/auth/phone_entry_screen.dart';
import 'package:booking_system_flutter/screens/blog/view/blog_list_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/customer_rating_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/screens/service/favourite_service_screen.dart';
import 'package:booking_system_flutter/screens/setting_screen.dart';
import 'package:booking_system_flutter/screens/wallet/user_wallet_balance_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/extensions/num_extenstions.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_configuration.dart';
import '../../bankDetails/view/bank_details.dart';
import '../../favourite_provider_screen.dart';
import '../../helpDesk/help_desk_list_screen.dart';
import '../component/wallet_history.dart';

class ProfileFragment extends StatefulWidget {
  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<num>? futureWalletBalance;

  @override
  void initState() {
    super.initState();
    init();
    afterBuildCreated(() {
      appStore.setLoading(false);
      setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    });
  }

  Future<void> init() async {
    if (appStore.isLoggedIn) {
      appStore.setUserWalletAmount();
      userDetailAPI();
    }
  }

  Future<void> userDetailAPI() async {
    await getUserDetail(appStore.userId, forceUpdate: false).then((value) async {
      await saveUserData(value, forceSyncAppConfigurations: false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget _buildProfileHeader(BuildContext context) {
    final bool isDark = appStore.isDarkMode;
    return Container(
      width: context.width(),
      decoration: BoxDecoration(
        gradient: isDark ? appBarGradient : appBarGradientLight,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row with title + settings
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Text(language.profile, style: boldTextStyle(color: Colors.white, size: 20)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: Colors.white.withValues(alpha: 0.9), size: 22),
                    onPressed: () => SettingScreen().launch(context),
                  ),
                ],
              ),
            ),
            16.height,
            // Avatar + info
            if (appStore.isLoggedIn)
              GestureDetector(
                onTap: () => EditProfileScreen().launch(context),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                          ),
                          child: CachedImageWidget(
                            url: appStore.userProfileImage,
                            height: 80,
                            width: 80,
                            circle: true,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Icon(Icons.edit, size: 14, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                    12.height,
                    Text(
                      appStore.userFullName,
                      style: boldTextStyle(color: Colors.white, size: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.height,
                    Text(
                      appStore.userEmail,
                      style: secondaryTextStyle(color: Colors.white.withValues(alpha: 0.7), size: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            24.height,
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    final bool isDark = appStore.isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      transform: Matrix4.translationValues(0, -20, 0),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: darkBorderGlow, width: 1) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: primaryColor.withValues(alpha: 0.08), blurRadius: 16, offset: Offset(0, 4)),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ic_wallet_cartoon.iconImage(size: 24),
          ),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language.walletBalance, style: secondaryTextStyle(size: 12)),
              4.height,
              Text(appStore.userWalletAmount.toPriceFormat(), style: boldTextStyle(size: 20, color: primaryColor)),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Top Up', style: boldTextStyle(size: 12, color: Colors.white)),
          ).onTap(() {
            if (appConfigurationStore.onlinePaymentStatus) {
              UserWalletBalanceScreen().launch(context);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? iconBgColor,
    Widget? trailing,
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
                color: (iconBgColor ?? primaryColor).withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon.iconImage(size: 18, color: iconBgColor ?? primaryColor),
            ),
            16.width,
            Text(title, style: primaryTextStyle(size: 14)).expand(),
            if (trailing != null) trailing,
            if (trailing == null) Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemWithMaterialIcon({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconBgColor,
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
                color: (iconBgColor ?? primaryColor).withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconBgColor ?? primaryColor),
            ),
            16.width,
            Text(title, style: primaryTextStyle(size: 14)).expand(),
            Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    Color? titleColor,
  }) {
    final bool isDark = appStore.isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: darkBorderGlow, width: 1) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 2)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title.toUpperCase(),
              style: boldTextStyle(size: 11, color: titleColor ?? primaryColor, letterSpacing: 1.2),
            ),
          ),
          ...children,
          8.height,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (BuildContext context) {
          return Stack(
            children: [
              AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                padding: EdgeInsets.only(bottom: 32),
                crossAxisAlignment: CrossAxisAlignment.center,
                onSwipeRefresh: () async {
                  await removeKey(LAST_USER_DETAILS_SYNCED_TIME);
                  init();
                  setState(() {});
                  return 1.seconds.delay;
                },
                children: [
                  _buildProfileHeader(context),
                  // Wallet card
                  if (appStore.isLoggedIn)
                    Observer(builder: (_) => _buildWalletCard(context)),
                  // General section
                  Observer(builder: (context) {
                    return _buildSectionCard(
                      context: context,
                      title: language.lblGENERAL,
                      children: [
                        if (appStore.isLoggedIn && appConfigurationStore.isEnableUserWallet)
                          _buildMenuItem(
                            context: context,
                            icon: ic_wallet_history,
                            title: language.walletHistory,
                            iconBgColor: Color(0xFF7C3AED),
                            onTap: () => UserWalletHistoryScreen().launch(context),
                          ),
                        if (appStore.isLoggedIn && rolesAndPermissionStore.bankList)
                          _buildMenuItem(
                            context: context,
                            icon: ic_card,
                            title: language.lblBankDetails,
                            iconBgColor: Color(0xFF0EA5E9),
                            onTap: () => BankDetails().launch(context),
                          ),
                        if (appStore.isLoggedIn)
                          _buildMenuItem(
                            context: context,
                            icon: ic_heart,
                            title: language.lblFavorite,
                            iconBgColor: Color(0xFFEF4444),
                            onTap: () => doIfLoggedIn(context, () => FavouriteServiceScreen().launch(context)),
                          ),
                        if (appStore.isLoggedIn)
                          _buildMenuItem(
                            context: context,
                            icon: ic_profile2,
                            title: language.favouriteProvider,
                            iconBgColor: Color(0xFF10B981),
                            onTap: () => doIfLoggedIn(context, () => FavouriteProviderScreen().launch(context)),
                          ),
                        if (appConfigurationStore.blogStatus && rolesAndPermissionStore.blogList)
                          _buildMenuItem(
                            context: context,
                            icon: ic_document,
                            title: language.blogs,
                            iconBgColor: Color(0xFFF59E0B),
                            onTap: () => BlogListScreen().launch(context),
                          ),
                        _buildMenuItem(
                          context: context,
                          icon: ic_star,
                          title: language.rateUs,
                          iconBgColor: Color(0xFFF59E0B),
                          onTap: () async {
                            if (isAndroid) {
                              if (getStringAsync(CUSTOMER_PLAY_STORE_URL).isNotEmpty) {
                                commonLaunchUrl(getStringAsync(CUSTOMER_PLAY_STORE_URL), launchMode: LaunchMode.externalApplication);
                              } else {
                                commonLaunchUrl('${getSocialMediaLink(LinkProvider.PLAY_STORE)}${await getPackageName()}', launchMode: LaunchMode.externalApplication);
                              }
                            } else if (isIOS) {
                              if (getStringAsync(CUSTOMER_APP_STORE_URL).isNotEmpty) {
                                commonLaunchUrl(getStringAsync(CUSTOMER_APP_STORE_URL), launchMode: LaunchMode.externalApplication);
                              } else {
                                commonLaunchUrl(IOS_LINK_FOR_USER, launchMode: LaunchMode.externalApplication);
                              }
                            }
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: ic_my_review,
                          title: language.myReviews,
                          iconBgColor: Color(0xFF8B5CF6),
                          onTap: () => doIfLoggedIn(context, () => CustomerRatingScreen().launch(context)),
                        ),
                        if (appStore.isLoggedIn && rolesAndPermissionStore.helpDeskList)
                          _buildMenuItem(
                            context: context,
                            icon: ic_help_desk,
                            title: language.helpDesk,
                            iconBgColor: Color(0xFF06B6D4),
                            onTap: () => HelpDeskListScreen().launch(context),
                          ),
                      ],
                    );
                  }),
                  // About section
                  _buildSectionCard(
                    context: context,
                    title: language.lblAboutApp,
                    children: [
                      if (rolesAndPermissionStore.aboutUs)
                        _buildMenuItem(
                          context: context,
                          icon: ic_about_us,
                          title: language.lblAboutApp,
                          iconBgColor: Color(0xFF1B3A5C),
                          onTap: () => AboutScreen().launch(context),
                        ),
                      if (rolesAndPermissionStore.privacyPolicy)
                        _buildMenuItem(
                          context: context,
                          icon: ic_shield_done,
                          title: language.privacyPolicy,
                          iconBgColor: Color(0xFF10B981),
                          onTap: () => checkIfLink(context, appConfigurationStore.privacyPolicy, title: language.privacyPolicy),
                        ),
                      if (rolesAndPermissionStore.termCondition)
                        _buildMenuItem(
                          context: context,
                          icon: ic_document,
                          title: language.termsCondition,
                          iconBgColor: Color(0xFF64748B),
                          onTap: () => checkIfLink(context, appConfigurationStore.termConditions, title: language.termsCondition),
                        ),
                      if (rolesAndPermissionStore.refundAndCancellationPolicy)
                        _buildMenuItem(
                          context: context,
                          icon: ic_refund,
                          title: language.refundPolicy,
                          iconBgColor: Color(0xFFF97316),
                          onTap: () => checkIfLink(context, appConfigurationStore.refundPolicy, title: language.refundPolicy),
                        ),
                      if (appConfigurationStore.helpAndSupport.isNotEmpty && rolesAndPermissionStore.helpAndSupport)
                        _buildMenuItem(
                          context: context,
                          icon: ic_helpAndSupport,
                          title: language.helpSupport,
                          iconBgColor: Color(0xFF3B82F6),
                          onTap: () {
                            if (appConfigurationStore.helpAndSupport.isNotEmpty) {
                              checkIfLink(context, appConfigurationStore.helpAndSupport, title: language.helpSupport);
                            } else {
                              checkIfLink(context, appConfigurationStore.inquiryEmail.validate(), title: language.helpSupport);
                            }
                          },
                        ),
                      if (appConfigurationStore.helplineNumber.isNotEmpty)
                        _buildMenuItem(
                          context: context,
                          icon: ic_calling,
                          title: language.lblHelplineNumber,
                          iconBgColor: Color(0xFF22C55E),
                          onTap: () => launchCall(appConfigurationStore.helplineNumber.validate()),
                        ),
                      if (!appStore.isLoggedIn)
                        _buildMenuItemWithMaterialIcon(
                          context: context,
                          icon: MaterialCommunityIcons.login,
                          title: language.signIn,
                          iconBgColor: primaryColor,
                          onTap: () => PhoneEntryScreen().launch(context),
                        ),
                    ],
                  ),
                  // Danger zone
                  if (appStore.isLoggedIn)
                    _buildSectionCard(
                      context: context,
                      title: language.lblDangerZone,
                      titleColor: Color(0xFFEF4444),
                      children: [
                        _buildMenuItemWithMaterialIcon(
                          context: context,
                          icon: Icons.delete_outline,
                          title: language.lblDeleteAccount,
                          iconBgColor: Color(0xFFEF4444),
                          onTap: () {
                            showConfirmDialogCustom(
                              context,
                              negativeText: language.lblCancel,
                              positiveText: language.lblDelete,
                              onAccept: (_) {
                                ifNotTester(() {
                                  appStore.setLoading(true);
                                  deleteAccountCompletely().then((value) async {
                                    try {
                                      await userService.removeDocument(appStore.uid);
                                      await userService.deleteUser();
                                    } catch (e) {
                                      print(e);
                                    }
                                    appStore.setLoading(false);
                                    await clearPreferences();
                                    toast(value.message);
                                    push(DashboardScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
                                  }).catchError((e) {
                                    appStore.setLoading(false);
                                    toast(e.toString());
                                  });
                                });
                              },
                              dialogType: DialogType.DELETE,
                              title: language.lblDeleteAccountConformation,
                            );
                          },
                        ),
                      ],
                    ),
                  // Logout button
                  if (appStore.isLoggedIn)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: OutlinedButton.icon(
                        onPressed: () => logout(context),
                        icon: Icon(MaterialCommunityIcons.logout, size: 18),
                        label: Text(language.logout, style: boldTextStyle(size: 14, color: primaryColor)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: Size(double.infinity, 48),
                        ),
                      ),
                    ),
                  // Version info
                  SnapHelperWidget<PackageInfoData>(
                    future: getPackageInfo(),
                    onSuccess: (data) {
                      return TextButton(
                        child: VersionInfoWidget(prefixText: 'v', textStyle: secondaryTextStyle(size: 12)),
                        onPressed: () {
                          showAboutDialog(
                            context: context,
                            applicationName: APP_NAME,
                            applicationVersion: data.versionName,
                            applicationIcon: Image.asset(appLogo, height: 50),
                          );
                        },
                      ).center();
                    },
                  ),
                  16.height,
                ],
              ),
              Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading)),
            ],
          );
        },
      ),
    );
  }
}
