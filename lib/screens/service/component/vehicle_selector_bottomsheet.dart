import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/component/empty_error_state_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/category_model.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';

class VehicleSelectorBottomsheet extends StatefulWidget {
  const VehicleSelectorBottomsheet({super.key});

  @override
  State<VehicleSelectorBottomsheet> createState() =>
      _VehicleSelectorBottomsheetState();
}

class _VehicleSelectorBottomsheetState
    extends State<VehicleSelectorBottomsheet> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0-3

  // Data
  Future<DashboardResponse>? _dashboardFuture;
  List<CategoryData> _categories = [];

  // Step 1 — Vehicle Type
  CategoryData? _selectedCategory;

  // Step 2 — Brand (subcategory)
  Future<List<CategoryData>>? _subcategoryFuture;
  List<CategoryData> _subcategories = [];
  CategoryData? _selectedSubCategory;

  // Step 3 — Vehicle (service)
  Future<List<ServiceData>>? _serviceFuture;
  List<ServiceData> _services = [];
  ServiceData? _selectedService;

  // Step 2 — Brand search
  String _brandSearchQuery = '';

  // Step 4 — Plan
  ServicePlanData? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = userDashboard(
      isCurrentLocation: appStore.isCurrentLocation,
      lat: getDoubleAsync(LATITUDE),
      long: getDoubleAsync(LONGITUDE),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onCategorySelected(CategoryData cat) {
    setState(() {
      _selectedCategory = cat;
      // Reset downstream
      _subcategories = [];
      _selectedSubCategory = null;
      _services = [];
      _selectedService = null;
      _selectedPlan = null;
      _brandSearchQuery = '';
    });
  }

  void _onNext() {
    if (_currentStep == 0 && _selectedCategory != null) {
      // Load subcategories then go to step 2
      _subcategoryFuture =
          getSubCategoryListAPI(catId: _selectedCategory!.id.validate());
      _subcategoryFuture!.then((list) {
        setState(() => _subcategories = list);
      });
      _goToStep(1);
    } else if (_currentStep == 1 && _selectedSubCategory != null) {
      // Load services then go to step 3
      _serviceFuture = searchServiceAPI(
        categoryId: _selectedCategory!.id.toString(),
        subCategory: _selectedSubCategory!.id.toString(),
        list: [],
      );
      _serviceFuture!.then((list) {
        setState(() => _services = list);
      });
      _goToStep(2);
    } else if (_currentStep == 2 && _selectedService != null) {
      _goToStep(3);
    }
  }

  void _onBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _onConfirm() {
    if (_selectedPlan == null ||
        _selectedCategory == null ||
        _selectedService == null) return;

    final result = SelectedVehiclePlan(
      vehicleType: _selectedCategory!.name ?? 'Unknown',
      vehicleName: _selectedService!.name ?? 'Unknown',
      model: _selectedSubCategory?.name ?? 'Unknown',
      price: double.tryParse(_selectedPlan!.amount ?? '0') ?? 0.0,
      planId: _selectedPlan!.id,
      serviceId: _selectedService!.id,
      planName: _selectedPlan!.name ?? '',
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SnapHelperWidget<DashboardResponse>(
        future: _dashboardFuture,
        loadingWidget: const Loader(),
        errorBuilder: (error) => NoDataWidget(
          title: error,
          imageWidget: ErrorStateWidget(),
          retryText: language.reload,
          onRetry: () {
            setState(() {
              _dashboardFuture = userDashboard(
                isCurrentLocation: appStore.isCurrentLocation,
                lat: getDoubleAsync(LATITUDE),
                long: getDoubleAsync(LONGITUDE),
              );
            });
          },
        ),
        onSuccess: (snap) {
          _categories = snap.category.validate();
          return SafeArea(
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: appStore.isDarkMode
                          ? Colors.white38
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Step indicator
                _buildStepIndicator(),
                const SizedBox(height: 4),
                // Title
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    _stepTitle(),
                    style: boldTextStyle(
                      size: 18,
                      color:
                          appStore.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1VehicleType(),
                      _buildStep2Brand(),
                      _buildStep3Vehicle(),
                      _buildStep4Plan(),
                    ],
                  ),
                ),
                // Bottom buttons
                _buildBottomButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Step 1 of 4: Vehicle Type';
      case 1:
        return 'Step 2 of 4: Select Brand';
      case 2:
        return 'Step 3 of 4: Select Vehicle';
      case 3:
        return 'Step 4 of 4: Choose Plan';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted || isCurrent
                    ? context.primaryColor
                    : (appStore.isDarkMode
                        ? Colors.white24
                        : Colors.grey[300]),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Vehicle Type ──────────────────────────────────────────

  Widget _buildStep1VehicleType() {
    if (_categories.isEmpty) {
      return const Center(child: Text('No vehicle types available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: _categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory?.id == cat.id;

          return GestureDetector(
            onTap: () => _onCategorySelected(cat),
            child: Container(
              decoration: BoxDecoration(
                color: appStore.isDarkMode ? darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? context.primaryColor
                      : appStore.isDarkMode
                          ? darkBorderGlow.withOpacity(0.5)
                          : const Color(0xFFE0E0E0),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.primaryColor.withOpacity(0.15),
                          blurRadius: 10,
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _categoryImage(cat, 48),
                  const SizedBox(height: 8),
                  Text(
                    cat.name ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: appStore.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoryImage(CategoryData cat, double size) {
    final url = cat.categoryImage ?? '';
    if (url.endsWith('.svg')) {
      return SvgPicture.network(
        url,
        width: size,
        height: size,
        color: appStore.isDarkMode ? Colors.white : null,
      );
    }
    return CachedImageWidget(
      url: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      circle: true,
    );
  }

  // ── Step 2: Select Brand (subcategory) ────────────────────────────

  Widget _buildStep2Brand() {
    if (_subcategoryFuture == null) {
      return const Center(child: Text('Select a vehicle type first'));
    }

    return FutureBuilder<List<CategoryData>>(
      future: _subcategoryFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: Loader());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text('No brands available'));
        }

        final filteredList = _brandSearchQuery.isEmpty
            ? list
            : list.where((s) => (s.name ?? '').toLowerCase().contains(_brandSearchQuery.toLowerCase())).toList();

        return Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: appStore.isDarkMode ? darkSurface : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appStore.isDarkMode ? darkBorderGlow.withOpacity(0.3) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _brandSearchQuery = value);
                  },
                  style: TextStyle(
                    fontSize: 14,
                    color: appStore.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search brand...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: appStore.isDarkMode ? Colors.white38 : Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: appStore.isDarkMode ? Colors.white38 : Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            if (filteredList.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No brands match "$_brandSearchQuery"',
                    style: TextStyle(color: appStore.isDarkMode ? Colors.white54 : Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: appStore.isDarkMode
                        ? darkBorderGlow.withOpacity(0.3)
                        : const Color(0xFFE0E0E0),
                  ),
                  itemBuilder: (context, index) {
                    final sub = filteredList[index];
                    final isSelected = _selectedSubCategory?.id == sub.id;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? context.primaryColor
                            : (appStore.isDarkMode ? Colors.white54 : Colors.black38),
                      ),
                      title: Text(
                        sub.name ?? '',
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: appStore.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: context.primaryColor, size: 20)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedSubCategory = sub;
                          // Reset downstream
                          _services = [];
                          _selectedService = null;
                          _selectedPlan = null;
                        });
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

  // ── Step 3: Select Vehicle (service) ──────────────────────────────

  Widget _buildStep3Vehicle() {
    if (_serviceFuture == null) {
      return const Center(child: Text('Select a brand first'));
    }

    return FutureBuilder<List<ServiceData>>(
      future: _serviceFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: Loader());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text('No vehicles found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: list.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: appStore.isDarkMode
                ? darkBorderGlow.withOpacity(0.3)
                : const Color(0xFFE0E0E0),
          ),
          itemBuilder: (context, index) {
            final service = list[index];
            final isSelected = _selectedService?.id == service.id;

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? context.primaryColor
                    : (appStore.isDarkMode ? Colors.white54 : Colors.black38),
              ),
              title: Text(
                service.name ?? '',
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: context.primaryColor, size: 20)
                  : null,
              onTap: () {
                setState(() {
                  _selectedService = service;
                  _selectedPlan = null;
                });
              },
            );
          },
        );
      },
    );
  }

  // ── Step 4: Choose Plan ───────────────────────────────────────────

  Widget _buildStep4Plan() {
    final plans = _selectedService?.plans ?? [];
    if (plans.isEmpty) {
      return const Center(child: Text('No plans available for this vehicle'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isSelected = _selectedPlan?.id == plan.id;
        final amount = plan.amount ?? '0';
        final title = plan.name ?? 'Plan';
        final items = plan.items ?? [];
        final washType = plan.washType ?? '';

        String? badge;
        if (index == 1 && plans.length > 1) badge = 'MOST POPULAR';
        if (index == plans.length - 1 && plans.length > 2) badge = 'BEST VALUE';

        return GestureDetector(
          onTap: () {
            setState(() => _selectedPlan = plan);
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appStore.isDarkMode ? darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? context.primaryColor
                    : appStore.isDarkMode
                        ? darkBorderGlow.withOpacity(0.5)
                        : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.primaryColor.withOpacity(0.15),
                        blurRadius: 12,
                      )
                    ]
                  : appStore.isDarkMode
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.06),
                            blurRadius: 12,
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          )
                        ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (badge != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badge == 'MOST POPULAR'
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badge == 'MOST POPULAR'
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appStore.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '\u20B9$amount/month',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (washType.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.autorenew,
                          size: 16,
                          color: appStore.isDarkMode
                              ? Colors.white70
                              : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '$washType washes/month',
                        style: TextStyle(
                          fontSize: 13,
                          color: appStore.isDarkMode
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                ...items.map((item) {
                  final isActive = item.status == 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isActive
                              ? Colors.green
                              : Colors.red.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                              decoration: isActive
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 20,
                        color: isSelected
                            ? context.primaryColor
                            : (appStore.isDarkMode
                                ? Colors.white54
                                : Colors.black38),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSelected ? 'Selected' : 'Select',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? context.primaryColor
                              : (appStore.isDarkMode
                                  ? Colors.white54
                                  : Colors.black38),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Buttons ────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    final bool canGoNext;
    switch (_currentStep) {
      case 0:
        canGoNext = _selectedCategory != null;
        break;
      case 1:
        canGoNext = _selectedSubCategory != null;
        break;
      case 2:
        canGoNext = _selectedService != null;
        break;
      case 3:
        canGoNext = _selectedPlan != null;
        break;
      default:
        canGoNext = false;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: appStore.isDarkMode
                ? darkBorderGlow.withOpacity(0.3)
                : const Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: appStore.isDarkMode
                        ? Colors.white54
                        : Colors.black38,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _onBack,
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: appStore.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canGoNext ? context.primaryColor : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: canGoNext
                  ? (_currentStep == 3 ? _onConfirm : _onNext)
                  : null,
              child: Text(
                _currentStep == 3 ? 'Confirm' : 'Next',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
