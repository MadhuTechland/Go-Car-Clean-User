import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/city_list_model.dart';
import 'package:booking_system_flutter/model/country_list_model.dart';
import 'package:booking_system_flutter/model/login_model.dart';
import 'package:booking_system_flutter/model/state_list_model.dart';
import 'package:booking_system_flutter/network/network_utils.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/loader_widget.dart';
import '../../utils/configs.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  File? imageFile;
  XFile? pickedFile;

  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];

  CountryListResponse? selectedCountry;
  StateListResponse? selectedState;
  CityListResponse? selectedCity;

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();

  ValueNotifier _valueNotifier = ValueNotifier(true);

  int countryId = 0;
  int stateId = 0;
  int cityId = 0;

  Country selectedCountryCode = defaultCountry();

  bool isEmailVerified = getBoolAsync(IS_EMAIL_VERIFIED);

  bool showRefresh = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      appStore.setLoading(true);
    });

    countryId = getIntAsync(COUNTRY_ID);
    stateId = getIntAsync(STATE_ID);
    cityId = getIntAsync(CITY_ID);

    fNameCont.text = appStore.userFirstName;
    lNameCont.text = appStore.userLastName;
    emailCont.text = appStore.userEmail;
    userNameCont.text = appStore.userName;
    mobileCont.text = appStore.userContactNumber.split("-").last;
    countryId = appStore.countryId;
    stateId = appStore.stateId;
    cityId = appStore.cityId;
    addressCont.text = appStore.address;
    selectedCountryCode = Country(
      countryCode: appStore.userContactNumber.split("-").last,
      phoneCode: appStore.userContactNumber.split("-").first.isEmpty ? "91" : appStore.userContactNumber.split("-").first,
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: '',
      example: '',
      displayName: '',
      displayNameNoCountryCode: '',
      e164Key: '',
      fullExampleWithPlusSign: '',
    );

    userDetailAPI();

    if (getIntAsync(COUNTRY_ID) != 0) {
      await getCountry();
      setState(() {});
    } else {
      await getCountry();
    }
  }

  String buildMobileNumber() {
    if (mobileCont.text.isEmpty) {
      return '';
    } else {
      return '${selectedCountryCode.phoneCode}-${mobileCont.text.trim()}';
    }
  }

  Future<void> userDetailAPI() async {
    await getUserDetail(appStore.userId).then((value) {
      isEmailVerified = value.emailVerified.validate().getBoolInt();
      setValue(IS_EMAIL_VERIFIED, isEmailVerified);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> getCountry() async {
    await getCountryList().then((value) async {
      countryList.clear();
      countryList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(COUNTRY_ID))) {
        selectedCountry = value.firstWhere((element) => element.id == getIntAsync(COUNTRY_ID));
      }

      setState(() {});
      await getStates(getIntAsync(COUNTRY_ID));
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getStates(int countryId) async {
    appStore.setLoading(true);
    await getStateList({UserKeys.countryId: countryId}).then((value) async {
      stateList.clear();
      stateList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(STATE_ID))) {
        selectedState = value.firstWhere((element) => element.id == getIntAsync(STATE_ID));
      }

      setState(() {});
      if (getIntAsync(STATE_ID) != 0) {
        await getCity(getIntAsync(STATE_ID));
      }
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getCity(int stateId) async {
    appStore.setLoading(true);

    await getCityList({UserKeys.stateId: stateId}).then((value) async {
      cityList.clear();
      cityList.addAll(value);

      if (value.any((element) => element.id == getIntAsync(CITY_ID))) {
        selectedCity = value.firstWhere((element) => element.id == getIntAsync(CITY_ID));
      }

      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> update() async {
    hideKeyboard(context);

    MultipartRequest multiPartRequest = await getMultiPartRequest('update-profile');
    multiPartRequest.fields[UserKeys.id] = appStore.userId.toString();
    multiPartRequest.fields[UserKeys.firstName] = fNameCont.text;
    multiPartRequest.fields[UserKeys.lastName] = lNameCont.text;
    multiPartRequest.fields[UserKeys.userName] = userNameCont.text;
    multiPartRequest.fields[UserKeys.contactNumber] = buildMobileNumber();
    multiPartRequest.fields[UserKeys.email] = emailCont.text;
    multiPartRequest.fields[UserKeys.countryId] = countryId.toString();
    multiPartRequest.fields[UserKeys.stateId] = stateId.toString();
    multiPartRequest.fields[UserKeys.cityId] = cityId.toString();
    multiPartRequest.fields[CommonKeys.address] = addressCont.text;
    multiPartRequest.fields[UserKeys.displayName] = '${fNameCont.text.validate() + " " + lNameCont.text.validate()}';
    if (imageFile != null) {
      multiPartRequest.files.add(await MultipartFile.fromPath(UserKeys.profileImage, imageFile!.path));
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());
    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);
        if (data != null) {
          if ((data as String).isJson()) {
            LoginResponse res = LoginResponse.fromJson(jsonDecode(data));

            if (FirebaseAuth.instance.currentUser != null) {
              userService.updateDocument({
                'profile_image': res.userData!.profileImage.validate(),
                'updated_at': Timestamp.now().toDate().toString(),
              }, FirebaseAuth.instance.currentUser!.uid);
            }

            saveUserData(res.userData!);
            finish(context);
            toast(res.message.validate().capitalizeFirstLetter());
          }
        }
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
    }
  }

  _getFromCamera() async {
    pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
    }
  }

  Future<void> verifyEmail() async {
    appStore.setLoading(true);

    await verifyUserEmail(emailCont.text).then((value) async {
      isEmailVerified = value.isEmailVerified.validate().getBoolInt();

      toast(value.message);

      await setValue(IS_EMAIL_VERIFIED, isEmailVerified);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void _showBottomSheet(BuildContext context) {
    final bool isDark = appStore.isDarkMode;
    showModalBottomSheet<void>(
      backgroundColor: isDark ? darkSurfaceVariant : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Choose Photo', style: boldTextStyle(size: 16)),
              20.height,
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _getFromCamera();
                        finish(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: isDark ? Border.all(color: darkBorderGlow) : null,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt_outlined, color: primaryColor, size: 24),
                            ),
                            12.height,
                            Text(language.camera, style: primaryTextStyle(size: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  16.width,
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _getFromGallery();
                        finish(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Color(0xFF7C3AED).withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: isDark ? Border.all(color: darkBorderGlow) : null,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF7C3AED).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.photo_library_outlined, color: Color(0xFF7C3AED), size: 24),
                            ),
                            12.height,
                            Text(language.lblGallery, style: primaryTextStyle(size: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        textStyle: secondaryTextStyle(color: textSecondaryColorGlobal),
        searchTextStyle: primaryTextStyle(),
        inputDecoration: InputDecoration(
          labelText: language.search,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withValues(alpha: 0.2),
            ),
          ),
        ),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        selectedCountryCode = country;
        setState(() {});
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          10.width,
          Text(label.toUpperCase(), style: boldTextStyle(size: 11, color: primaryColor, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    final bool isDark = appStore.isDarkMode;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: darkBorderGlow, width: 1) : null,
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = appStore.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(language.editProfile, style: boldTextStyle(color: Colors.white, size: APP_BAR_TEXT_SIZE)),
        elevation: 0,
        backgroundColor: context.primaryColor,
        leading: context.canPop ? BackButton(color: Colors.white) : null,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              return await userDetailAPI();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              physics: AlwaysScrollableScrollPhysics(),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile avatar section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24),
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
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [primaryColor.withValues(alpha: 0.3), primaryColor],
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? darkSurfaceVariant : Colors.white,
                                  ),
                                  child: imageFile != null
                                      ? Image.file(
                                          imageFile!,
                                          width: 96,
                                          height: 96,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(48)
                                      : Observer(
                                          builder: (_) => CachedImageWidget(
                                            url: appStore.userProfileImage,
                                            height: 96,
                                            width: 96,
                                            fit: BoxFit.cover,
                                            radius: 48,
                                          ),
                                        ),
                                ),
                              ),
                              if (!isLoginTypeGoogle && !isLoginTypeApple)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _showBottomSheet(context),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isDark ? darkSurfaceVariant : Colors.white, width: 3),
                                        boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: Offset(0, 2))],
                                      ),
                                      child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          12.height,
                          Text(appStore.userFullName, style: boldTextStyle(size: 16)),
                          4.height,
                          Text('@${appStore.userName}', style: secondaryTextStyle(size: 13, color: primaryColor)),
                        ],
                      ),
                    ),
                    20.height,

                    // Personal info section
                    _buildSectionLabel('Personal Info'),
                    _buildFormCard(
                      children: [
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: fNameCont,
                          focus: fNameFocus,
                          errorThisFieldRequired: language.requiredText,
                          nextFocus: lNameFocus,
                          enabled: !isLoginTypeApple,
                          decoration: inputDecoration(context, labelText: language.hintFirstNameTxt),
                          suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: lNameCont,
                          focus: lNameFocus,
                          errorThisFieldRequired: language.requiredText,
                          nextFocus: userNameFocus,
                          enabled: !isLoginTypeApple,
                          decoration: inputDecoration(context, labelText: language.hintLastNameTxt),
                          suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                        ),
                        16.height,
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: userNameCont,
                          focus: userNameFocus,
                          enabled: false,
                          errorThisFieldRequired: language.requiredText,
                          nextFocus: emailFocus,
                          decoration: inputDecoration(context, labelText: language.hintUserNameTxt),
                          suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
                        ),
                      ],
                    ),
                    20.height,

                    // Contact section
                    _buildSectionLabel('Contact'),
                    _buildFormCard(
                      children: [
                        AppTextField(
                          textFieldType: TextFieldType.EMAIL_ENHANCED,
                          controller: emailCont,
                          focus: emailFocus,
                          nextFocus: mobileFocus,
                          errorThisFieldRequired: language.requiredText,
                          decoration: inputDecoration(context, labelText: language.hintEmailTxt),
                          suffix: ic_message.iconImage(size: 10).paddingAll(14),
                          autoFillHints: [AutofillHints.email],
                          onFieldSubmitted: (email) async {
                            if (emailCont.text.isNotEmpty) await verifyEmail();
                          },
                        ),
                        // Email verification badge
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Container(
                            margin: EdgeInsets.only(top: 6),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isEmailVerified
                                  ? Color(0xFF10B981).withValues(alpha: 0.1)
                                  : Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isEmailVerified ? Icons.check_circle : Icons.warning_amber_rounded,
                                  size: 14,
                                  color: isEmailVerified ? Color(0xFF10B981) : Colors.amber.shade700,
                                ),
                                6.width,
                                Text(
                                  isEmailVerified ? language.verified : language.verifyEmail,
                                  style: boldTextStyle(
                                    size: 11,
                                    color: isEmailVerified ? Color(0xFF10B981) : Colors.amber.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ).onTap(() {
                            if (!isEmailVerified) verifyEmail();
                          }),
                        ),
                        12.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Country code picker
                            InkWell(
                              onTap: () => changeCountry(),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 48,
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                margin: EdgeInsets.only(bottom: context.height() * 0.032),
                                decoration: BoxDecoration(
                                  color: isDark ? quickActionCardBg : context.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isDark ? Border.all(color: darkBorderGlow) : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: _valueNotifier,
                                      builder: (context, value, child) => Text(
                                        "+${selectedCountryCode.phoneCode}",
                                        style: primaryTextStyle(size: 13),
                                      ),
                                    ),
                                    4.width,
                                    Icon(Icons.keyboard_arrow_down, size: 18, color: isDark ? Colors.white54 : Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            10.width,
                            Expanded(
                              child: AppTextField(
                                textFieldType: isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                                controller: mobileCont,
                                focus: mobileFocus,
                                enabled: !isLoginTypeOTP,
                                isValidationRequired: false,
                                errorThisFieldRequired: language.requiredText,
                                decoration: inputDecoration(context, hintText: '${language.hintContactNumberTxt}').copyWith(
                                  hintStyle: secondaryTextStyle(),
                                ),
                                maxLength: 15,
                                suffix: ic_calling.iconImage(size: 10).paddingAll(14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    20.height,

                    // Location section
                    _buildSectionLabel('Location'),
                    _buildFormCard(
                      children: [
                        Row(
                          children: [
                            DropdownButtonFormField<CountryListResponse>(
                              decoration: inputDecoration(context, labelText: language.selectCountry),
                              isExpanded: true,
                              value: selectedCountry,
                              dropdownColor: context.cardColor,
                              items: countryList.map((CountryListResponse e) {
                                return DropdownMenuItem<CountryListResponse>(
                                  value: e,
                                  child: Text(
                                    e.name!,
                                    style: primaryTextStyle(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (CountryListResponse? value) async {
                                hideKeyboard(context);
                                countryId = value!.id!;
                                selectedCountry = value;
                                selectedState = null;
                                selectedCity = null;
                                getStates(value.id!);
                                setState(() {});
                              },
                            ).expand(),
                            if (stateList.isNotEmpty) ...[
                              8.width,
                              DropdownButtonFormField<StateListResponse>(
                                decoration: inputDecoration(context, labelText: language.selectState),
                                isExpanded: true,
                                dropdownColor: context.cardColor,
                                value: selectedState,
                                items: stateList.map((StateListResponse e) {
                                  return DropdownMenuItem<StateListResponse>(
                                    value: e,
                                    child: Text(
                                      e.name!,
                                      style: primaryTextStyle(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (StateListResponse? value) async {
                                  hideKeyboard(context);
                                  selectedCity = null;
                                  selectedState = value;
                                  stateId = value!.id!;
                                  await getCity(value.id!);
                                  setState(() {});
                                },
                              ).expand(),
                            ],
                          ],
                        ),
                        if (cityList.isNotEmpty) ...[
                          16.height,
                          DropdownButtonFormField<CityListResponse>(
                            decoration: inputDecoration(context, labelText: language.selectCity),
                            isExpanded: true,
                            value: selectedCity,
                            dropdownColor: context.cardColor,
                            items: cityList.map((CityListResponse e) {
                              return DropdownMenuItem<CityListResponse>(
                                value: e,
                                child: Text(e.name!, style: primaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (CityListResponse? value) async {
                              hideKeyboard(context);
                              selectedCity = value;
                              cityId = value!.id!;
                              setState(() {});
                            },
                          ),
                        ],
                        16.height,
                        AppTextField(
                          controller: addressCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 4,
                          decoration: inputDecoration(context, labelText: language.hintAddress),
                          suffix: ic_location.iconImage(size: 10).paddingAll(14),
                          isValidationRequired: false,
                        ),
                      ],
                    ),
                    32.height,

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ifNotTester(() {
                            update();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          shadowColor: primaryColor.withValues(alpha: 0.3),
                        ),
                        child: Text(language.save, style: boldTextStyle(color: Colors.white, size: 15)),
                      ),
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
