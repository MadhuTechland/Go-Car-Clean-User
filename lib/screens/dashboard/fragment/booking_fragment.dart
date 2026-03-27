import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_detail_screen.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_component_screen.dart';
import 'package:booking_system_flutter/screens/booking/shimmer/booking_shimmer.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../store/filter_store.dart';
import '../../booking_filter/booking_filter_screen.dart';

class BookingFragment extends StatefulWidget {
  @override
  _BookingFragmentState createState() => _BookingFragmentState();
}

class _BookingFragmentState extends State<BookingFragment> with TickerProviderStateMixin {
  late TabController _tabController;

  Future<List<BookingData>>? future;
  List<BookingData> bookings = [];

  int page = 1;
  bool isLastPage = false;

  String selectedValue = BOOKING_TYPE_ALL;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    init();
    filterStore = FilterStore();

    afterBuildCreated(() {
      if (appStore.isLoggedIn) {
        setStatusBarColor(context.primaryColor);
      }
    });

    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_LIST, (p0) {
      page = 1;
      appStore.setLoading(true);
      init();
      setState(() {});
    });
    cachedBookingStatusDropdown.validate().forEach((element) {
      element.isSelected = false;
    });
  }

  void init({String status = ''}) async {
    future = getBookingList(
      page,
      serviceId: filterStore.serviceId.join(","),
      dateFrom: filterStore.startDate,
      dateTo: filterStore.endDate,
      providerId: filterStore.providerId.join(","),
      handymanId: filterStore.handymanId.join(","),
      bookingStatus: filterStore.bookingStatus.join(","),
      paymentStatus: filterStore.paymentStatus.join(","),
      paymentType: filterStore.paymentType.join(","),
      bookings: bookings,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _tabController.dispose();
    filterStore.clearFilters();
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKING_LIST);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = appStore.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? darkSurface : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(language.booking, style: boldTextStyle(color: white, size: APP_BAR_TEXT_SIZE)),
        backgroundColor: context.primaryColor,
        elevation: 0,
        actions: [
          Observer(
            builder: (_) {
              int filterCount = filterStore.getActiveFilterCount();
              return Stack(
                children: [
                  IconButton(
                    icon: ic_filter.iconImage(color: white, size: 20),
                    onPressed: () async {
                      BookingFilterScreen(showHandymanFilter: true).launch(context).then((value) {
                        if (value != null) {
                          page = 1;
                          appStore.setLoading(true);
                          init();
                          setState(() {});
                        }
                      });
                    },
                  ),
                  if (filterCount > 0)
                    Positioned(
                      right: 7,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: boxDecorationDefault(color: Colors.red, shape: BoxShape.circle),
                        child: FittedBox(
                          child: Text('$filterCount', style: const TextStyle(color: white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? darkSurfaceVariant : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: primaryColor,
              unselectedLabelColor: isDark ? Colors.white60 : Colors.white.withValues(alpha: 0.85),
              labelStyle: boldTextStyle(size: 13),
              unselectedLabelStyle: primaryTextStyle(size: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on_rounded, size: 16),
                      6.width,
                      const Text("Instant"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 16),
                      6.width,
                      const Text("Daily"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _BookingTab(
                bookingType: BOOKING_TYPE_INSTANT,
                future: future,
                page: page,
                isLastPage: isLastPage,
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);
                    init(status: selectedValue);
                    setState(() {});
                  }
                },
                onRefresh: () {
                  page = 1;
                  appStore.setLoading(true);
                  init(status: selectedValue);
                  setState(() {});
                },
              ),
              _BookingTab(
                bookingType: BOOKING_TYPE_DAILY,
                future: future,
                page: page,
                isLastPage: isLastPage,
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);
                    init(status: selectedValue);
                    setState(() {});
                  }
                },
                onRefresh: () {
                  page = 1;
                  appStore.setLoading(true);
                  init(status: selectedValue);
                  setState(() {});
                },
              ),
            ],
          ),
          Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}

class _BookingTab extends StatefulWidget {
  final String bookingType;
  final Future<List<BookingData>>? future;
  final int page;
  final bool isLastPage;
  final VoidCallback onNextPage;
  final VoidCallback onRefresh;

  const _BookingTab({
    required this.bookingType,
    required this.future,
    required this.page,
    required this.isLastPage,
    required this.onNextPage,
    required this.onRefresh,
  });

  @override
  State<_BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends State<_BookingTab> with AutomaticKeepAliveClientMixin {
  UniqueKey keyForList = UniqueKey();
  ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SnapHelperWidget<List<BookingData>>(
      initialData: cachedBookingList,
      future: widget.future,
      errorBuilder: (error) {
        return NoDataWidget(
          title: error,
          imageWidget: ErrorStateWidget(),
          retryText: language.reload,
          onRetry: widget.onRefresh,
        );
      },
      loadingWidget: BookingShimmer(),
      onSuccess: (list) {
        List<BookingData> filteredList = list.where((e) => e.bookingsType == widget.bookingType).toList();
        final isDark = appStore.isDarkMode;

        return Column(
          children: [
            // Summary strip
            if (filteredList.isNotEmpty)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [primaryColor.withValues(alpha: 0.12), primaryColor.withValues(alpha: 0.04)]
                        : [primaryColor.withValues(alpha: 0.06), primaryColor.withValues(alpha: 0.02)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.bookingType == BOOKING_TYPE_INSTANT ? Icons.flash_on_rounded : Icons.calendar_month_rounded,
                      size: 18,
                      color: primaryColor,
                    ),
                    8.width,
                    Text(
                      '${filteredList.length} ${widget.bookingType == BOOKING_TYPE_INSTANT ? "Instant" : "Daily"} Booking${filteredList.length != 1 ? 's' : ''}',
                      style: boldTextStyle(size: 13, color: primaryColor),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_downward_rounded, size: 14, color: primaryColor.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            Expanded(
              child: AnimatedListView(
                key: keyForList,
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 60, top: 12, right: 16, left: 16),
                itemCount: filteredList.length,
                shrinkWrap: true,
                disposeScrollController: false,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                slideConfiguration: SlideConfiguration(verticalOffset: 400),
                emptyWidget: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.bookingType == BOOKING_TYPE_INSTANT
                              ? Icons.flash_off_rounded
                              : Icons.event_busy_rounded,
                          size: 48,
                          color: primaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                      20.height,
                      Text(
                        language.lblNoBookingsFound,
                        style: boldTextStyle(size: 16, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      8.height,
                      Text(
                        widget.bookingType == BOOKING_TYPE_INSTANT
                            ? 'Your instant wash bookings will appear here'
                            : 'Your daily wash subscriptions will appear here',
                        style: secondaryTextStyle(size: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (_, index) {
                  BookingData data = filteredList[index];
                  return GestureDetector(
                    onTap: () {
                      BookingDetailScreen(bookingId: data.id.validate()).launch(context);
                    },
                    child: BookingComponent(bookingData: data),
                  );
                },
                onNextPage: widget.onNextPage,
                onSwipeRefresh: () async {
                  widget.onRefresh();
                  return await 1.seconds.delay;
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
