import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../constants/constants.dart';

class ListingDetailPage extends StatefulWidget {
  final ListingDetail listing;

  const ListingDetailPage({
    Key? key,
    required this.listing,
  }) : super(key: key);

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header with Image Carousel
          SliverAppBar(
            expandedHeight: detailHeaderHeight,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarousel(
                images: widget.listing.images,
                isLandlordVerified: widget.listing.isLandlordVerified,
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: tabPaddingHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: tabPaddingVertical),

                  // Listing Header
                  ListingDetailHeader(
                    title: widget.listing.title,
                    address: widget.listing.address,
                    price: widget.listing.price,
                    slotsAvailable: widget.listing.slotsAvailable,
                    tags: widget.listing.tags,
                  ),
                  const SizedBox(height: sectionSpacing),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Location'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: tabPaddingHorizontal),
              height: 600, // Approximate height for tab content
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Overview Tab
                  OverviewTab(
                    description: widget.listing.description,
                    inclusions: widget.listing.inclusions,
                    houseRules: widget.listing.houseRules,
                    landlordName: widget.listing.landlordName,
                    isLandlordVerified: widget.listing.isLandlordVerified,
                  ),

                  // Location Tab
                  LocationTab(
                    address: widget.listing.address,
                    barangay: widget.listing.barangay,
                    nearbyLandmarks: widget.listing.nearbyLandmarks,
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons at Bottom
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(tabPaddingHorizontal),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: tabPaddingVertical),
                  ActionButtons(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
