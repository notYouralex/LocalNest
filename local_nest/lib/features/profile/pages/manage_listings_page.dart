import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme/theme.dart';
import '../constants/manage_listings_constants.dart';
import '../models/listing_model.dart';
import '../presentation/widgets/listing_card.dart';
import '../presentation/widgets/add_listing_button.dart';
import '../../listings/repositories/firestore_listing_repository.dart';
import 'add_listing_page.dart';

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
  final FirestoreListingRepository _repository = FirestoreListingRepositoryImpl();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadListingsFromFirestore();
  }

  /// Load real listings from Firestore
  Future<void> _loadListingsFromFirestore() async {
    try {
      setState(() => _isLoading = true);
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Fetch landlord's listings from Firestore
      final firestoreListings = await _repository.getListingsByLandlord(currentUser.uid);
      
      // Convert Firestore Listing to UI Listing model
      _listings = firestoreListings.map((firestoreListing) {
        return Listing(
          id: firestoreListing.id,
          title: firestoreListing.propertyName,
          address: '${firestoreListing.completeAddress}, ${firestoreListing.city}',
          price: '₱${firestoreListing.monthlyRent.toStringAsFixed(0)}/mo',
          roomType: firestoreListing.roomType,
          available: '${firestoreListing.availableSlots}/${firestoreListing.totalSlots} slots',
          views: firestoreListing.views,
          inquiries: firestoreListing.inquiries,
          isActive: firestoreListing.status == 'active',
          createdAt: firestoreListing.createdAt,
        );
      }).toList();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load listings: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Calculate stats from listings
  ListingsStats _getStats() => ListingsStats.fromListings(_listings);

  void _handleAddListing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddListingPage(),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh listings after new listing is added
        _loadListingsFromFirestore();
      }
    });
  }

  Future<void> _handleToggleListing(Listing listing) async {
    try {
      // Optimistically update UI
      setState(() {
        final index = _listings.indexWhere((l) => l.id == listing.id);
        if (index != -1) {
          _listings[index] = _listings[index].toggleStatus();
        }
      });

      // Update status in Firestore
      final firestoreListing = await _repository.getListingById(listing.id);
      if (firestoreListing != null) {
        final updatedListing = firestoreListing.copyWith(
          status: listing.isActive ? 'inactive' : 'active',
          updatedAt: DateTime.now(),
        );
        await _repository.updateListing(updatedListing);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        final index = _listings.indexWhere((l) => l.id == listing.id);
        if (index != -1) {
          _listings[index] = _listings[index].toggleStatus();
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  void _handleEditListing(String id) async {
    try {
      // Fetch the listing from Firestore
      final firestoreListing = await _repository.getListingById(id);
      
      if (firestoreListing == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing not found')),
          );
        }
        return;
      }
      
      // Navigate to add listing page in edit mode
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddListingPage(listing: firestoreListing),
          ),
        );
        
        // Refresh listings if update was successful
        if (result == true) {
          _loadListingsFromFirestore();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load listing: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteListing(String id) async {
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
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                // Delete from Firestore
                await _repository.deleteListing(id);
                
                // Update UI
                setState(() => _listings.removeWhere((l) => l.id == id));
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(ManageListingsConstants.successDeleteMessage),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete listing: $e')),
                  );
                }
              }
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
                onPressed: _loadListingsFromFirestore,
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
