import 'dart:async';

import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/base_scaffold_body.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_up_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final String contactNumber;
  final bool? isFromDashboard;
  final bool? isFromServiceBooking;
  final bool returnExpected;

  OtpVerificationScreen({
    required this.phoneNumber,
    required this.countryCode,
    required this.contactNumber,
    this.isFromDashboard,
    this.isFromServiceBooking,
    this.returnExpected = false,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String otpCode = '';
  int _resendSeconds = OTP_RESEND_SECONDS;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = OTP_RESEND_SECONDS;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        _resendSeconds--;
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOtp() async {
    appStore.setLoading(true);

    Map<String, dynamic> request = {
      'contact_number': widget.contactNumber,
    };

    try {
      await sendPhoneOtp(request);
      appStore.setLoading(false);
      toast(language.otpCodeIsSentToYourMobileNumber);
      _startResendTimer();
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
    }
  }

  void _verifyOtp() async {
    if (otpCode.length < OTP_TEXT_FIELD_LENGTH) {
      toast(language.pleaseEnterValidOTP);
      return;
    }

    hideKeyboard(context);
    appStore.setLoading(true);

    Map<String, dynamic> request = {
      'contact_number': widget.contactNumber,
      'otp': otpCode,
    };

    try {
      final response = await loginWithPhoneOtp(request);

      if (response.isUserExist == true && response.userData != null) {
        // Existing user — save data and go to dashboard
        await saveUserData(response.userData!);
        await appStore.setLoginType(LOGIN_TYPE_OTP);
        await setValue(USER_PASSWORD, widget.phoneNumber);

        authService.verifyFirebaseUser();

        _onLoginSuccessRedirection();
      } else {
        // New user — go to registration
        appStore.setLoading(false);

        SignUpScreen(
          isOTPLogin: true,
          phoneNumber: widget.phoneNumber,
          countryCode: widget.countryCode,
        ).launch(context, isNewTask: true);
      }
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
    }
  }

  void _onLoginSuccessRedirection() {
    afterBuildCreated(() {
      appStore.setLoading(false);
      if (widget.isFromServiceBooking.validate() || widget.isFromDashboard.validate() || widget.returnExpected.validate()) {
        if (widget.isFromDashboard.validate()) {
          push(DashboardScreen(redirectToBooking: true), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          finish(context, true);
        }
      } else {
        DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      }
    });
  }

  String _maskedPhone() {
    String phone = widget.phoneNumber;
    if (phone.length > 4) {
      return '+${widget.countryCode == 'IN' ? '91' : widget.countryCode}${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
    }
    return phone;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.confirmOTP, style: boldTextStyle(size: APP_BAR_TEXT_SIZE)),
          elevation: 0,
          backgroundColor: context.scaffoldBackgroundColor,
          leading: Navigator.of(context).canPop() ? BackWidget(iconColor: context.iconColor) : null,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
            statusBarColor: context.scaffoldBackgroundColor,
          ),
        ),
        body: Body(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                32.height,
                // Subtitle
                Text(
                  '${language.otpCodeIsSentToYourMobileNumber}\n${_maskedPhone()}',
                  style: secondaryTextStyle(size: 14, color: appStore.isDarkMode ? greetingTextColor : null),
                  textAlign: TextAlign.center,
                ),
                32.height,
                // OTP input
                OTPTextField(
                  pinLength: OTP_TEXT_FIELD_LENGTH,
                  textStyle: primaryTextStyle(),
                  decoration: inputDecoration(context, fillColor: appStore.isDarkMode ? quickActionCardBg : null).copyWith(
                    counter: Offstage(),
                  ),
                  onChanged: (s) {
                    otpCode = s;
                  },
                  onCompleted: (pin) {
                    otpCode = pin;
                    _verifyOtp();
                  },
                ).fit(),
                30.height,
                // Verify button
                Container(
                  decoration: BoxDecoration(
                    boxShadow: appStore.isDarkMode
                        ? [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 0, offset: Offset(0, 4))]
                        : [],
                  ),
                  child: AppButton(
                    onTap: _verifyOtp,
                    text: language.confirm,
                    color: primaryColor,
                    textColor: Colors.white,
                    width: context.width(),
                  ),
                ),
                24.height,
                // Resend timer / button
                if (_resendSeconds > 0)
                  Text(
                    '${'Resend OTP'} in ${_resendSeconds}s',
                    style: secondaryTextStyle(),
                  )
                else
                  TextButton(
                    onPressed: _resendOtp,
                    child: Text(
                      'Resend OTP',
                      style: boldTextStyle(color: primaryColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
