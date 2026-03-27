import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/category/shimmer/category_shimmer.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/empty_error_state_widget.dart';
import '../../utils/constant.dart';
import '../service/view_all_service_screen.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<CategoryData>> future;
  List<CategoryData> categoryList = [];

  int page = 1;
  bool isLastPage = false;

  UniqueKey key = UniqueKey();

  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getCategoryListWithPagination(page, categoryList: categoryList, lastPageCallBack: (val) {
      isLastPage = val;
    });
    if (page == 1) {
      key = UniqueKey();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Color _getCategoryAccentColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('car')) return Color(0xFF1B3A5C);
    if (lower.contains('bike')) return Color(0xFFEC4899);
    if (lower.contains('scooty') || lower.contains('scooter')) return Color(0xFF10B981);
    if (lower.contains('bus') || lower.contains('van') || lower.contains('truck')) return Color(0xFFF59E0B);
    return primaryColor;
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('car')) return Icons.directions_car_rounded;
    if (lower.contains('bike')) return Icons.two_wheeler_rounded;
    if (lower.contains('scooty') || lower.contains('scooter')) return Icons.electric_scooter_rounded;
    if (lower.contains('bus')) return Icons.directions_bus_rounded;
    if (lower.contains('van')) return Icons.airport_shuttle_rounded;
    if (lower.contains('truck')) return Icons.local_shipping_rounded;
    return Icons.directions_car_rounded;
  }

  Widget _buildVehicleCard(CategoryData data) {
    final isDark = appStore.isDarkMode;
    final Color accentColor = _getCategoryAccentColor(data.name.validate());
    final bool isSvg = data.categoryImage.validate().endsWith('.svg');
    final int serviceCount = data.services ?? 0;
    final bool hasImage = data.categoryImage.validate().isNotEmpty;

    return GestureDetector(
      onTap: () {
        ViewAllServiceScreen(categoryId: data.id.validate(), categoryName: data.name, isFromCategory: true).launch(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? darkSurfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? accentColor.withValues(alpha: 0.25) : Colors.grey.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative accent circle in top-right
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: isDark ? 0.06 : 0.04),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: image + arrow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle image container
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: hasImage
                            ? (isSvg
                                ? SvgPicture.network(
                                    data.categoryImage.validate(),
                                    height: 36,
                                    width: 36,
                                    colorFilter: ColorFilter.mode(isDark ? Colors.white : accentColor, BlendMode.srcIn),
                                    placeholderBuilder: (context) => Icon(
                                      _getCategoryIcon(data.name.validate()),
                                      size: 32,
                                      color: accentColor,
                                    ),
                                  ).center()
                                : CachedImageWidget(
                                    url: data.categoryImage.validate(),
                                    fit: BoxFit.contain,
                                    width: 44,
                                    height: 44,
                                    circle: false,
                                    placeHolderImage: '',
                                  ).center())
                            : Icon(
                                _getCategoryIcon(data.name.validate()),
                                size: 32,
                                color: isDark ? Colors.white70 : accentColor,
                              ).center(),
                      ),
                      const Spacer(),
                      // Arrow button
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: isDark ? Colors.white70 : accentColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Vehicle name
                  Text(
                    data.name.validate(),
                    style: boldTextStyle(size: 16, color: isDark ? Colors.white : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.height,
                  // Service count
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      8.width,
                      Flexible(
                        child: Text(
                          serviceCount > 0
                              ? '$serviceCount ${serviceCount == 1 ? 'service' : 'services'} available'
                              : 'Explore services',
                          style: secondaryTextStyle(
                            size: 12,
                            color: isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? scaffoldColorDark : Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? scaffoldColorDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, size: 20, color: isDark ? Colors.white : Colors.black87),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Vehicle',
              style: boldTextStyle(size: 18, color: isDark ? Colors.white : Colors.black87),
            ),
            Text(
              'Select a vehicle type to explore services',
              style: secondaryTextStyle(size: 12),
            ),
          ],
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<CategoryData>>(
            initialData: cachedCategoryList,
            future: future,
            loadingWidget: CategoryShimmer(),
            onSuccess: (snap) {
              if (snap.isEmpty) {
                return NoDataWidget(
                  title: language.noCategoryFound,
                  imageWidget: EmptyStateWidget(),
                );
              }

              return AnimatedScrollView(
                onSwipeRefresh: () async {
                  page = 1;
                  init();
                  setState(() {});
                  return await 2.seconds.delay;
                },
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);
                    init();
                    setState(() {});
                  }
                },
                children: [
                  GridView.builder(
                    key: key,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: snap.length,
                    itemBuilder: (_, index) {
                      return _buildVehicleCard(snap[index]);
                    },
                  ),
                ],
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: ErrorStateWidget(),
                retryText: language.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);
                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (BuildContext context) => LoaderWidget().visible(appStore.isLoading.validate())),
        ],
      ),
    );
  }
}
