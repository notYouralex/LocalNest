import 'package:flutter/material.dart';
import '../../../app/theme/theme.dart';
import '../constants/manage_listings_constants.dart';
import '../models/listing_model.dart';
import '../presentation/widgets/listing_card.dart';
import '../presentation/widgets/add_listing_button.dart';

/// Manage Listings page for landlords
/// Shows all property listings with management options
class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});

  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  late List<Listing> _listings;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Initialize listings synchronously
  void _initializeData() {
    try {
      // Initialize with default/mock data immediately
      _listings = [
        Listing(
          id: '1',
          title: 'Cozy Haven Boarding House',
          address: '123 P. Noval St., Sampaloc',
          price: '₱5,500/mo',
          roomType: 'Solo',
          available: '3/5 slots',
          views: 234,
          inquiries: 12,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Listing(
          id: '2',
          title: 'Student Hub Residence',
          address: '456 Dapitan St., Sampaloc',
          price: '₱4,800/mo',
          roomType: 'Shared',
          available: '2/8 slots',
          views: 189,
          inquiries: 8,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
        Listing(
          id: '3',
          title: 'Modern Studio Suites',
          address: '789 España Blvd., Sampaloc',
          price: '₱12,000/mo',
          roomType: 'Studio',
          available: '0/4 slots',
          views: 456,
          inquiries: 23,
          isActive: false,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ];

      // Mark as loaded
      if (mounted) {
        setState(() => _isLoading = false);
      }

      // TODO: In real app, fetch from Firebase here asynchronously
      _loadListingsFromBackend();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load listings: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Load listings from Firebase/backend (non-blocking)
  Future<void> _loadListingsFromBackend() async {
    try {
      // TODO: Replace with actual Firebase call
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // TODO: Update with real listings
      // _listings = await FirestoreService.instance
      //     .collection('listings')
      //     .where('landlordId', isEqualTo: currentUserId)
      //     .get()
      //     .then((snap) => snap.docs.map((doc) => Listing.fromJson(doc.data())).toList());
      
      setState(() {
        // Data updated if needed
      });
    } catch (e) {
      debugPrint('Error loading listings: $e');
      // Don't show error for background loading, just keep initial data
    }
  }

  /// Legacy async load - replaced with sync init above
  Future<void> _loadListings() async {
    try {
      setState(() => _isLoading = true);

      // TODO: Replace with actual Firebase call
      await Future.delayed(const Duration(milliseconds: 300));

      _listings = [
        Listing(
          id: '1',
          title: 'Cozy Haven Boarding House',
          address: '123 P. Noval St., Sampaloc',
          price: '₱5,500/mo',
          roomType: 'Solo',
          available: '3/5 slots',
          views: 234,
          inquiries: 12,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Listing(
          id: '2',
          title: 'Student Hub Residence',
          address: '456 Dapitan St., Sampaloc',
          price: '₱4,800/mo',
          roomType: 'Shared',
          available: '2/8 slots',
          views: 189,
          inquiries: 8,
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
        ),
        Listing(
          id: '3',
          title: 'Modern Studio Suites',
          address: '789 España Blvd., Sampaloc',
          price: '₱12,000/mo',
          roomType: 'Studio',
          available: '0/4 slots',
          views: 456,
          inquiries: 23,
          isActive: false,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ];

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load listings: $e';
        _isLoading = false;
      });
    }
  }

  /// Calculate stats from listings
  ListingsStats _getStats() => ListingsStats.fromListings(_listings);

  void _handleAddListing() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(ManageListingsConstants.addListingComingSoon),
      ),
    );
    // TODO: Navigate to create listing page
  }

  void _handleToggleListing(Listing listing) {
    setState(() {
      final index = _listings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _listings[index] = _listings[index].toggleStatus();
      }
    });
    // TODO: Save to backend
  }

  void _handleDeactivateListing(String id) {
    setState(() {
      final index = _listings.indexWhere((l) => l.id == id);
      if (index != -1) {
        _listings[index] = _listings[index].toggleStatus();
      }
    });
    // TODO: Save to backend
  }

  void _handleActivateListing(String id) {
    setState(() {
      final index = _listings.indexWhere((l) => l.id == id);
      if (index != -1) {
        _listings[index] = _listings[index].toggleStatus();
      }
    });
    // TODO: Save to backend
  }

  void _handleEditListing(String id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${ManageListingsConstants.editListingComingSoon} $id'),
      ),
    );
    // TODO: Navigate to edit listing page
  }

  void _handleDeleteListing(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ManageListingsConstants.deleteDialogTitle),
        content: const Text(ManageListingsConstants.deleteDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(ManageListingsConstants.cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              setState(() => _listings.removeWhere((l) => l.id == id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(ManageListingsConstants.successDeleteMessage),
                ),
              );
              // TODO: Delete from backend
            },
            child: Text(
              ManageListingsConstants.deleteButtonLabel,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadListings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = _getStats();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with gradient
          _buildHeader(),
          // Stats
          _buildStatsSection(stats),
          // Listings
          Expanded(
            child: _listings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No listings yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first listing to get started',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _handleAddListing,
                          icon: const Icon(Icons.add),
                          label: const Text(
                            ManageListingsConstants.addListingButton,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(
                      ManageListingsConstants.contentPadding,
                    ),
                    itemCount: _listings.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: ManageListingsConstants.cardSpacing,
                        ),
                        child: ListingCard(
                          listing: _listings[index],
                          onEdit: () => _handleEditListing(_listings[index].id),
                          onToggleStatus: () => _handleToggleListing(_listings[index]),
                          onDelete: () => _handleDeleteListing(_listings[index].id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: ManageListingsConstants.contentPadding,
        vertical: ManageListingsConstants.contentPadding,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Title and Add button
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: ManageListingsConstants.headerBackButtonSize,
                    height: ManageListingsConstants.headerBackButtonSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        ManageListingsConstants.buttonBorderRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.textWhite,
                      size: ManageListingsConstants.headerBackButtonIconSize,
                    ),
                  ),
                ),
                const SizedBox(
                  width: ManageListingsConstants.itemSpacing,
                ),
                Text(
                  ManageListingsConstants.pageTitle,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textWhite,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                AddListingButton(onTap: _handleAddListing),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ListingsStats stats) {
    return Padding(
      padding: const EdgeInsets.all(ManageListingsConstants.contentPadding),
      child: Row(
        children: [
          _buildStatItem(
            '${stats.activeCount}',
            ManageListingsConstants.activeCountStat,
          ),
          const SizedBox(width: ManageListingsConstants.itemSpacing),
          _buildStatItem(
            '${stats.totalViews}',
            ManageListingsConstants.viewsCountStat,
          ),
          const SizedBox(width: ManageListingsConstants.itemSpacing),
          _buildStatItem(
            '${stats.totalInquiries}',
            ManageListingsConstants.inquiriesCountStat,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: ManageListingsConstants.contentPadding,
          horizontal: ManageListingsConstants.itemSpacing,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: AppColors.border,
            width: ManageListingsConstants.borderWidth,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontSize: ManageListingsConstants.statFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
