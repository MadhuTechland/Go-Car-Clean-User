import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/empty_error_state_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';

class InstantWashScreen extends StatefulWidget {
  final String bookingType;

  const InstantWashScreen({super.key, this.bookingType = "instance"});

  @override
  State<InstantWashScreen> createState() => _InstantWashScreenState();
}

class _InstantWashScreenState extends State<InstantWashScreen> {
  Future<DashboardResponse>? future;
  CategoryData? selectedCategory;
  CategoryData? selectedSubcategory;
  Future<List<CategoryData>>? futureSubcategories;
  Future<List<ServiceData>>? futureServices;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    future = userDashboard(
      isCurrentLocation: appStore.isCurrentLocation,
      lat: getDoubleAsync(LATITUDE),
      long: getDoubleAsync(LONGITUDE),
    );
    setState(() {});
  }

  void loadSubcategories(int catId) {
    selectedSubcategory = null;
    futureServices = null;
    _searchController.clear();
    _searchQuery = '';
    futureSubcategories = getSubCategoryListAPI(catId: catId);
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void loadServices(CategoryData subCat, {String search = ''}) {
    selectedSubcategory = subCat;
    futureServices = searchServiceAPI(
      categoryId: selectedCategory!.id.toString(),
      subCategory: subCat.id.toString(),
      search: search,
      list: [],
    );
    setState(() {});
  }

  bool get isDaily => widget.bookingType == "daily";

  Color _getCategoryAccentColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('car')) return const Color(0xFF1B3A5C);
    if (lower.contains('bike')) return const Color(0xFFEC4899);
    if (lower.contains('scooty') || lower.contains('scooter')) return const Color(0xFF10B981);
    if (lower.contains('bus') || lower.contains('van') || lower.contains('truck')) return const Color(0xFFF59E0B);
    return primaryColor;
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('car')) return Icons.directions_car_rounded;
    if (lower.contains('bike')) return Icons.two_wheeler_rounded;
    if (lower.contains('scooty') || lower.contains('scooter')) return Icons.electric_scooter_rounded;
    if (lower.contains('bus') || lower.contains('van') || lower.contains('truck')) return Icons.directions_bus_rounded;
    return Icons.local_car_wash_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? darkSurface : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isDaily ? 'Daily Wash' : 'Instant Wash',
          style: boldTextStyle(size: 18, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SnapHelperWidget<DashboardResponse>(
        future: future,
        loadingWidget: const Loader(),
        errorBuilder: (error) => NoDataWidget(
          title: error,
          imageWidget: ErrorStateWidget(),
          retryText: language.reload,
          onRetry: () {
            appStore.setLoading(true);
            init();
          },
        ),
        onSuccess: (snap) {
          return Column(
            children: [
              // Step indicator + Vehicle selector
              _buildVehicleSelector(snap.category.validate(), isDark),

              // Content area
              Expanded(
                child: selectedCategory == null
                    ? _buildEmptyState(isDark)
                    : _buildSubcategoryAndServices(isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVehicleSelector(List<CategoryData> categories, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? darkSurfaceVariant : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              8.width,
              Text(
                'Select Your Vehicle',
                style: boldTextStyle(size: 15, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          12.height,
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => 12.width,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory?.id == cat.id;
                final accentColor = _getCategoryAccentColor(cat.name.validate());
                final icon = _getCategoryIcon(cat.name.validate());
                final bool isSvg = cat.categoryImage.validate().endsWith('.svg');

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                    loadSubcategories(cat.id.validate());
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha: isDark ? 0.2 : 0.1)
                          : isDark
                              ? quickActionCardBg
                              : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : isDark
                                ? quickActionCardBorder
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (cat.categoryImage.validate().isNotEmpty && isSvg)
                          SvgPicture.network(
                            cat.categoryImage.validate(),
                            height: 28,
                            width: 28,
                            colorFilter: ColorFilter.mode(
                              isSelected ? accentColor : (isDark ? Colors.white60 : Colors.grey.shade600),
                              BlendMode.srcIn,
                            ),
                            placeholderBuilder: (_) => Icon(icon, size: 28, color: isSelected ? accentColor : (isDark ? Colors.white60 : Colors.grey.shade600)),
                          )
                        else if (cat.categoryImage.validate().isNotEmpty)
                          CachedImageWidget(
                            url: cat.categoryImage.validate(),
                            height: 28,
                            width: 28,
                            fit: BoxFit.contain,
                          )
                        else
                          Icon(
                            icon,
                            size: 28,
                            color: isSelected ? accentColor : (isDark ? Colors.white60 : Colors.grey.shade600),
                          ),
                        8.height,
                        Text(
                          cat.name.validate(),
                          style: boldTextStyle(
                            size: 12,
                            color: isSelected
                                ? accentColor
                                : isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_car_wash_rounded,
              size: 48,
              color: primaryColor.withValues(alpha: 0.6),
            ),
          ),
          20.height,
          Text(
            'Choose a vehicle type above',
            style: boldTextStyle(size: 16, color: isDark ? Colors.white70 : Colors.black54),
          ),
          8.height,
          Text(
            isDaily ? 'to explore daily wash plans' : 'to explore instant wash services',
            style: secondaryTextStyle(size: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryAndServices(bool isDark) {
    return SnapHelperWidget<List<CategoryData>>(
      future: futureSubcategories,
      loadingWidget: const Loader(),
      onSuccess: (subCats) {
        if (subCats.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded, size: 40, color: Colors.grey.shade400),
                12.height,
                Text('No models available', style: secondaryTextStyle(size: 14)),
              ],
            ),
          );
        }

        // Auto-select first subcategory if none selected
        if (selectedSubcategory == null && subCats.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (selectedSubcategory == null) {
              loadServices(subCats.first);
            }
          });
        }

        // Filter subcategories based on search query
        final filteredSubCats = _searchQuery.isEmpty
            ? subCats
            : subCats.where((s) => s.name.validate().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? quickActionCardBg : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? quickActionCardBorder : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    // Also reload services with search query when a subcategory is selected
                    if (selectedSubcategory != null) {
                      loadServices(selectedSubcategory!, search: value.trim());
                    }
                  },
                  style: primaryTextStyle(size: 14, color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search brand or model...',
                    hintStyle: secondaryTextStyle(size: 14, color: isDark ? Colors.white38 : Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: isDark ? Colors.white38 : Colors.grey.shade400),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              if (selectedSubcategory != null) {
                                loadServices(selectedSubcategory!);
                              }
                            },
                            child: Icon(Icons.close_rounded, size: 18, color: isDark ? Colors.white38 : Colors.grey.shade400),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            // Subcategory header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  8.width,
                  Text(
                    'Select Model',
                    style: boldTextStyle(size: 15, color: isDark ? Colors.white : Colors.black87),
                  ),
                  const Spacer(),
                  if (_searchQuery.isNotEmpty)
                    Text(
                      '${filteredSubCats.length} found',
                      style: secondaryTextStyle(size: 12, color: primaryColor),
                    ),
                ],
              ),
            ),
            12.height,

            // Subcategory chips
            if (filteredSubCats.isNotEmpty)
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSubCats.length,
                  separatorBuilder: (_, __) => 8.width,
                  itemBuilder: (_, index) {
                    final sub = filteredSubCats[index];
                    final isSelected = selectedSubcategory?.id == sub.id;

                    return GestureDetector(
                      onTap: () => loadServices(sub),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : isDark
                                  ? quickActionCardBg
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : isDark
                                    ? quickActionCardBorder
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          sub.name.validate(),
                          style: boldTextStyle(
                            size: 13,
                            color: isSelected
                                ? Colors.white
                                : isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'No models match "$_searchQuery"',
                  style: secondaryTextStyle(size: 13, color: isDark ? Colors.white54 : Colors.grey.shade500),
                ),
              ),
            16.height,

            // Services list
            Expanded(
              child: futureServices == null
                  ? const SizedBox()
                  : FutureBuilder<List<ServiceData>>(
                      future: futureServices,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Loader();
                        }
                        if (snap.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, size: 36, color: Colors.red.shade300),
                                8.height,
                                Text('Something went wrong', style: secondaryTextStyle()),
                              ],
                            ),
                          );
                        }
                        if (!snap.hasData || snap.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
                                12.height,
                                Text('No services available', style: boldTextStyle(size: 14, color: Colors.grey)),
                                4.height,
                                Text('Try selecting a different model', style: secondaryTextStyle(size: 12)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: snap.data!.length,
                          itemBuilder: (_, index) {
                            return ServiceComponent(
                              serviceData: snap.data![index],
                              isFromViewAllService: true,
                              bookingType: widget.bookingType,
                            ).paddingBottom(12);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
