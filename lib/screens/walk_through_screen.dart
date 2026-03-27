import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../main.dart';

class WalkThroughScreen extends StatefulWidget {
  @override
  _WalkThroughScreenState createState() => _WalkThroughScreenState();
}

class _WalkThroughScreenState extends State<WalkThroughScreen> with TickerProviderStateMixin {
  List<WalkThroughModelClass> pages = [];
  int currentPage = 0;
  PageController pageController = PageController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    pageController = PageController(initialPage: 0);

    afterBuildCreated(() async {
      pages.add(WalkThroughModelClass(title: language.walkTitle1, image: walk_Img1, subTitle: language.walkThrough1));
      pages.add(WalkThroughModelClass(title: language.walkTitle2, image: walk_Img2, subTitle: language.walkThrough2));
      pages.add(WalkThroughModelClass(title: language.walkTitle3, image: walk_Img3, subTitle: language.walkThrough3));
      pages.add(WalkThroughModelClass(title: language.walkTitle4, image: walk_Img4, subTitle: language.walkThrough4));
      setState(() {});
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _goToDashboard() async {
    await setValue(IS_FIRST_TIME, false);
    DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
  }

  void _nextPage() {
    if (currentPage == pages.length - 1) {
      _goToDashboard();
    } else {
      pageController.nextPage(duration: 400.milliseconds, curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.width(),
        height: context.height(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: appStore.isDarkMode
                ? [
                    const Color(0xFF0A0D14),
                    const Color(0xFF111620),
                    const Color(0xFF0E1116),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF0F4FA),
                    const Color(0xFFE8EFF9),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Top bar with Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _goToDashboard,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: appStore.isDarkMode
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        child: Text(
                          language.lblSkip,
                          style: secondaryTextStyle(
                            size: 14,
                            color: appStore.isDarkMode
                                ? Colors.white.withValues(alpha: 0.6)
                                : appTextSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      if (pages.isEmpty) return const SizedBox();
                      WalkThroughModelClass page = pages[index];
                      return _buildPage(page, index);
                    },
                  ),
                ),

                // Bottom section: indicator + button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Page indicator
                      if (pages.isNotEmpty)
                        SmoothPageIndicator(
                          controller: pageController,
                          count: pages.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: primaryColor,
                            dotColor: appStore.isDarkMode
                                ? Colors.white.withValues(alpha: 0.2)
                                : primaryColor.withValues(alpha: 0.2),
                            dotHeight: 8,
                            dotWidth: 8,
                            expansionFactor: 4,
                            spacing: 6,
                          ),
                        ),

                      // Next / Get Started button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: currentPage == pages.length - 1
                            ? _buildGetStartedButton()
                            : _buildNextButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(WalkThroughModelClass page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative glow behind image
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: context.height() * 0.25,
                width: context.height() * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.12),
                      primaryColor.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Image.asset(
                page.image.validate(),
                height: context.height() * 0.32,
                fit: BoxFit.contain,
              ),
            ],
          ),
          40.height,

          // Step indicator pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: primaryColor.withValues(alpha: 0.12),
            ),
            child: Text(
              '${index + 1} / ${pages.length}',
              style: boldTextStyle(
                size: 12,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
          20.height,

          // Title
          Text(
            page.title.toString(),
            textAlign: TextAlign.center,
            style: boldTextStyle(
              size: 28,
              color: appStore.isDarkMode ? Colors.white : appTextPrimaryColor,
              weight: FontWeight.w700,
            ),
          ),
          16.height,

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              page.subTitle.toString(),
              textAlign: TextAlign.center,
              style: secondaryTextStyle(
                size: 15,
                color: appStore.isDarkMode
                    ? Colors.white.withValues(alpha: 0.55)
                    : appTextSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _nextPage,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _goToDashboard,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                primaryColor.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language.getStarted,
                style: boldTextStyle(size: 16, color: Colors.white),
              ),
              8.width,
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
