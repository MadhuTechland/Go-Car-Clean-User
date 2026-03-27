import 'dart:convert';

import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/otp_verification_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class PhoneEntryScreen extends StatefulWidget {
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;

  PhoneEntryScreen({this.isFromDashboard, this.isFromServiceBooking, this.returnExpected = false});

  @override
  _PhoneEntryScreenState createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController phoneCont = TextEditingController();
  FocusNode phoneFocus = FocusNode();
  Country selectedCountry = defaultCountry();

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() => appStore.setLoading(false));
  }

  void changeCountry() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(),
        inputDecoration: InputDecoration(
          labelText: language.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF8C98A8).withValues(alpha: 0.2)),
          ),
        ),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        selectedCountry = country;
        log(jsonEncode(selectedCountry.toJson()));
        setState(() {});
      },
    );
  }

  void _sendOtp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      String phoneNumber = phoneCont.text.trim();
      if (phoneNumber.length < 10) {
        toast(language.pleaseEnterValidOTP);
        return;
      }

      appStore.setLoading(true);

      String contactNumber = '${selectedCountry.phoneCode}-$phoneNumber';

      Map<String, dynamic> request = {
        'contact_number': contactNumber,
      };

      try {
        await sendPhoneOtp(request);
        appStore.setLoading(false);
        toast(language.otpCodeIsSentToYourMobileNumber);

        OtpVerificationScreen(
          phoneNumber: phoneNumber,
          countryCode: selectedCountry.countryCode,
          contactNumber: contactNumber,
          isFromDashboard: widget.isFromDashboard,
          isFromServiceBooking: widget.isFromServiceBooking,
          returnExpected: widget.returnExpected,
        ).launch(context);
      } catch (e) {
        appStore.setLoading(false);
        toast(e.toString());
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (widget.isFromServiceBooking.validate()) {
      setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.dark);
    } else if (widget.isFromDashboard.validate()) {
      setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.light);
    } else {
      setStatusBarColor(primaryColor, statusBarIconBrightness: Brightness.light);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Navigator.of(context).canPop()
              ? Container(
                  margin: EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: BackWidget(iconColor: context.iconColor),
                )
              : null,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarColor: context.scaffoldBackgroundColor,
          ),
        ),
        body: Body(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Observer(builder: (context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    (context.height() * 0.12).toInt().height,
                    // App logo with subtle glow
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: appStore.isDarkMode
                            ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 2)]
                            : [],
                      ),
                      child: Image.asset(appLogo, height: 72, width: 72),
                    ),
                    24.height,
                    // Welcome title
                    Text(language.lblLoginTitle, style: boldTextStyle(size: 24)).center(),
                    16.height,
                    Text(
                      language.lblLoginSubTitle,
                      style: primaryTextStyle(size: 14, color: appStore.isDarkMode ? greetingTextColor : null),
                      textAlign: TextAlign.center,
                    ).center().paddingSymmetric(horizontal: 32),
                    40.height,
                    // Phone input card
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: appStore.isDarkMode ? darkSurfaceVariant : context.cardColor,
                        borderRadius: radius(16),
                        border: appStore.isDarkMode ? Border.all(color: darkBorderGlow, width: 1) : null,
                        boxShadow: appStore.isDarkMode
                            ? [BoxShadow(color: primaryColor.withValues(alpha: 0.08), blurRadius: 16, spreadRadius: 0)]
                            : [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.lblEnterPhnNumber, style: boldTextStyle(size: 16)),
                          16.height,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Country code picker
                              Container(
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text("+${selectedCountry.phoneCode}", style: primaryTextStyle(size: 12)),
                                      Icon(Icons.arrow_drop_down, color: primaryColor),
                                    ],
                                  ).paddingOnly(left: 8),
                                ),
                              ).onTap(() => changeCountry()),
                              10.width,
                              // Phone number field
                              AppTextField(
                                controller: phoneCont,
                                focus: phoneFocus,
                                textFieldType: TextFieldType.PHONE,
                                decoration: inputDecoration(context).copyWith(
                                  hintText: '${language.lblExample}: ${selectedCountry.example}',
                                  hintStyle: secondaryTextStyle(),
                                ),
                                autoFocus: true,
                                onFieldSubmitted: (s) => _sendOtp(),
                              ).expand(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    30.height,
                    // Send OTP button
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: appStore.isDarkMode
                            ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 0, offset: Offset(0, 4))]
                            : [],
                      ),
                      child: AppButton(
                        text: language.btnSendOtp,
                        color: primaryColor,
                        textColor: Colors.white,
                        width: context.width() - context.navigationBarHeight,
                        onTap: _sendOtp,
                      ),
                    ),
                    30.height,
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
