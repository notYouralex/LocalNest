import 'package:flutter/material.dart';
import '../../listings/repositories/firestore_listing_repository.dart';
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
  final FirestoreListingRepository _repository = FirestoreListingRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Track view when page opens
    _trackView();
  }

  Future<void> _trackView() async {
    try {
      await _repository.incrementViews(widget.listing.id);
    } catch (e) {
      // Silently fail - don't interrupt user experience
      print('Failed to track view: $e');
    }
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
      body: SafeArea(
        top: false, // Allow image carousel to extend to top
        child: CustomScrollView(
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
                    landlordName: widget.listing.landlordName,
                    landlordProfileImageUrl: widget.listing.landlordProfileImageUrl,
                  ),

                  // Location Tab
                  LocationTab(
                    address: widget.listing.address,
                    barangay: widget.listing.barangay,
                    latitude: widget.listing.latitude,
                    longitude: widget.listing.longitude,
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
                  ActionButtons(
                    listingId: widget.listing.id,
                    listingTitle: widget.listing.title,
                    landlordId: widget.listing.landlordId,
                    landlordName: widget.listing.landlordName,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
