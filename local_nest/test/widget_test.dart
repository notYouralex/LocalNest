import 'package:flutter_test/flutter_test.dart';
import 'package:local_nest/features/listings/models/listing.dart';
import 'package:local_nest/features/listings/extensions/listing_extensions.dart';
import 'package:local_nest/features/home/models/listing_model.dart';
import 'package:local_nest/features/profile/models/user_profile.dart';
import 'package:local_nest/features/favorites/bloc/favorites_cubit.dart';

void main() {
  group('Listing and Model Extension Tests', () {
    final sampleListing = Listing(
      id: 'listing-123',
      landlordId: 'landlord-456',
      propertyName: 'Sunny Studio Dorm',
      completeAddress: '123 Main St, Near Campus',
      city: 'Cebu City',
      description: 'Cozy and spacious solo room with high-speed internet.',
      latitude: 10.3157,
      longitude: 123.8854,
      monthlyRent: 4500.0,
      roomType: 'Solo',
      availableSlots: 2,
      totalSlots: 5,
      genderPreference: 'Male Only',
      photoUrls: const ['https://example.com/photo1.jpg'],
      status: 'active',
      views: 12,
      inquiries: 3,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );

    test('Listing converts properly to ListingModel with favorite matching', () {
      final listingModel = sampleListing.toListingModel(
        favoriteIds: const ['listing-123'],
      );

      expect(listingModel.id, equals('listing-123'));
      expect(listingModel.title, equals('Sunny Studio Dorm'));
      expect(listingModel.price, equals(4500.0));
      expect(listingModel.isFavorite, isTrue);
      expect(listingModel.isAvailable, isTrue);
      expect(listingModel.genderPreference, equals('Male Only'));
      expect(listingModel.amenities, contains('Private Space'));
      expect(listingModel.amenities, contains('Male Only'));
    });

    test('Listing converts properly to ListingDetail preserving coordinates & landlordId', () {
      final listingDetail = sampleListing.toListingDetail(
        landlordName: 'John Doe',
        landlordProfileImageUrl: 'https://example.com/avatar.jpg',
      );

      expect(listingDetail.id, equals('listing-123'));
      expect(listingDetail.title, equals('Sunny Studio Dorm'));
      expect(listingDetail.landlordId, equals('landlord-456'));
      expect(listingDetail.landlordName, equals('John Doe'));
      expect(listingDetail.landlordProfileImageUrl, equals('https://example.com/avatar.jpg'));
      expect(listingDetail.latitude, equals(10.3157));
      expect(listingDetail.longitude, equals(123.8854));
      expect(listingDetail.slotsAvailable, equals(2));
      expect(listingDetail.images, contains('https://example.com/photo1.jpg'));
    });

    test('Listing copyWith works correctly', () {
      final updated = sampleListing.copyWith(
        propertyName: 'Updated Dorm Name',
        monthlyRent: 5000.0,
        availableSlots: 1,
      );

      expect(updated.propertyName, equals('Updated Dorm Name'));
      expect(updated.monthlyRent, equals(5000.0));
      expect(updated.availableSlots, equals(1));
      expect(updated.id, equals(sampleListing.id));
    });
  });

  group('UserProfile Model Tests', () {
    test('UserProfile serialization and props check', () {
      final userProfile = UserProfile(
        id: 'user-001',
        email: 'tenant@example.com',
        displayName: 'Jane Tenant',
        phoneNumber: '09123456789',
        userType: 'renter',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = userProfile.toJson();
      expect(json['id'], equals('user-001'));
      expect(json['email'], equals('tenant@example.com'));
      expect(json['userType'], equals('renter'));
      expect(userProfile.userType, equals('renter'));
    });

    test('RenterStats and NotificationSettings serialization', () {
      final stats = RenterStats(favorites: 5, messages: 3);
      expect(stats.favorites, equals(5));
      expect(stats.messages, equals(3));

      final updatedStats = stats.copyWith(favorites: 6);
      expect(updatedStats.favorites, equals(6));
      expect(updatedStats.messages, equals(3));

      final settings = NotificationSettings(newListings: true, messages: false);
      expect(settings.newListings, isTrue);
      expect(settings.messages, isFalse);
    });
  });

  group('FavoritesState Tests', () {
    test('FavoritesState tracks favorite listing IDs and loading correctly', () {
      const state = FavoritesState(
        favoriteIds: {'listing-1', 'listing-2'},
        isLoading: false,
      );

      expect(state.isFavorite('listing-1'), isTrue);
      expect(state.isFavorite('listing-3'), isFalse);

      final nextState = state.copyWith(
        favoriteIds: {'listing-1', 'listing-2', 'listing-3'},
      );

      expect(nextState.isFavorite('listing-3'), isTrue);
    });
  });
}
