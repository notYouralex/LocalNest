import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_nest/app/theme/app_colors.dart';
import '../../listings/models/listing.dart';
import '../bloc/add_listing_bloc.dart';
import '../repositories/listing_repository.dart';
import '../widgets/basic_info_section.dart';
import '../widgets/location_section.dart';
import '../widgets/pricing_capacity_section.dart';
import '../widgets/photos_section.dart';

/// AddListingPage - Main page for creating new property listings
///
/// This page follows Clean Architecture principles:
/// - Uses BLoC for state management
/// - Delegates form logic to BLoC
/// - Delegates validation to services
/// - Delegates data persistence to repository
/// - Composed of reusable widget sections for maintainability
class AddListingPage extends StatelessWidget {
  final Listing? listing; // Optional listing for edit mode

  const AddListingPage({super.key, this.listing});

  bool get isEditMode => listing != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddListingBloc(
        listingRepository: ListingRepositoryImpl(),
        initialListing: listing,
      ),
      child: BlocListener<AddListingBloc, AddListingState>(
        listener: (context, state) {
          if (state is AddListingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditMode
                      ? 'Listing updated successfully!'
                      : 'Listing created successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is AddListingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.primaryGradient,
                ),
              ),
            ),
            title: Text(isEditMode ? 'Edit Listing' : 'Add New Listing',style: TextStyle(color: Colors.white),),
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<AddListingBloc, AddListingState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BasicInfoSection(),
                    const SizedBox(height: 40),
                    const LocationSection(),
                    const SizedBox(height: 40),
                    const PricingCapacitySection(),
                    const SizedBox(height: 40),
                    const PhotosSection(),
                    const SizedBox(height: 40),
                    _buildSubmitButton(context, state),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AddListingState state) {
    final isLoading = state is AddListingLoading;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0f172a),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.cyan, Color(0xFF0891b2)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading
                    ? null
                    : () => context.read<AddListingBloc>().add(
                        const ListingSubmitted(),
                      ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            isEditMode ? 'Update Listing' : 'Publish Listing',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
