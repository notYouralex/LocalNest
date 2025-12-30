import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/listing_form_model.dart';
import '../repositories/listing_repository.dart';

// Events
abstract class AddListingEvent extends Equatable {
  const AddListingEvent();

  @override
  List<Object?> get props => [];
}

class PropertyNameChanged extends AddListingEvent {
  final String propertyName;
  const PropertyNameChanged(this.propertyName);

  @override
  List<Object?> get props => [propertyName];
}

class AddressChanged extends AddListingEvent {
  final String address;
  const AddressChanged(this.address);

  @override
  List<Object?> get props => [address];
}

class CityChanged extends AddListingEvent {
  final String city;
  const CityChanged(this.city);

  @override
  List<Object?> get props => [city];
}

class DescriptionChanged extends AddListingEvent {
  final String description;
  const DescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class RentChanged extends AddListingEvent {
  final String rent;
  const RentChanged(this.rent);

  @override
  List<Object?> get props => [rent];
}

class RoomTypeChanged extends AddListingEvent {
  final String roomType;
  const RoomTypeChanged(this.roomType);

  @override
  List<Object?> get props => [roomType];
}

class AvailableSlotsChanged extends AddListingEvent {
  final String slots;
  const AvailableSlotsChanged(this.slots);

  @override
  List<Object?> get props => [slots];
}

class TotalSlotsChanged extends AddListingEvent {
  final String slots;
  const TotalSlotsChanged(this.slots);

  @override
  List<Object?> get props => [slots];
}

class GenderPreferenceChanged extends AddListingEvent {
  final String preference;
  const GenderPreferenceChanged(this.preference);

  @override
  List<Object?> get props => [preference];
}

class AmenityToggled extends AddListingEvent {
  final String amenity;
  final bool value;
  const AmenityToggled(this.amenity, this.value);

  @override
  List<Object?> get props => [amenity, value];
}

class PhotosAdded extends AddListingEvent {
  final List<String> photoPaths;
  const PhotosAdded(this.photoPaths);

  @override
  List<Object?> get props => [photoPaths];
}

class PhotoRemoved extends AddListingEvent {
  final int index;
  const PhotoRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class ListingSubmitted extends AddListingEvent {
  const ListingSubmitted();
}

// States
abstract class AddListingState extends Equatable {
  const AddListingState();

  @override
  List<Object?> get props => [];
}

class AddListingInitial extends AddListingState {
  const AddListingInitial();
}

class AddListingFormUpdated extends AddListingState {
  final ListingFormData formData;
  final String? validationError;

  const AddListingFormUpdated(
    this.formData, {
    this.validationError,
  });

  @override
  List<Object?> get props => [formData, validationError];
}

class AddListingLoading extends AddListingState {
  const AddListingLoading();
}

class AddListingSuccess extends AddListingState {
  final String listingId;

  const AddListingSuccess(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class AddListingError extends AddListingState {
  final String message;

  const AddListingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AddListingBloc extends Bloc<AddListingEvent, AddListingState> {
  final ListingRepository _listingRepository;

  AddListingBloc({required ListingRepository listingRepository})
      : _listingRepository = listingRepository,
        super(const AddListingInitial()) {
    on<PropertyNameChanged>(_onPropertyNameChanged);
    on<AddressChanged>(_onAddressChanged);
    on<CityChanged>(_onCityChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<RentChanged>(_onRentChanged);
    on<RoomTypeChanged>(_onRoomTypeChanged);
    on<AvailableSlotsChanged>(_onAvailableSlotsChanged);
    on<TotalSlotsChanged>(_onTotalSlotsChanged);
    on<GenderPreferenceChanged>(_onGenderPreferenceChanged);
    on<AmenityToggled>(_onAmenityToggled);
    on<PhotosAdded>(_onPhotosAdded);
    on<PhotoRemoved>(_onPhotoRemoved);
    on<ListingSubmitted>(_onListingSubmitted);
  }

  ListingFormData _currentFormData = ListingFormData();

  Future<void> _onPropertyNameChanged(
    PropertyNameChanged event,
    Emitter<AddListingState> emit,
  ) async {
    _currentFormData = _currentFormData.copyWith(propertyName: event.propertyName);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onAddressChanged(
    AddressChanged event,
    Emitter<AddListingState> emit,
  ) async {
    _currentFormData = _currentFormData.copyWith(completeAddress: event.address);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onCityChanged(
    CityChanged event,
    Emitter<AddListingState> emit,
  ) async {
    _currentFormData = _currentFormData.copyWith(city: event.city);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<AddListingState> emit,
  ) async {
    _currentFormData = _currentFormData.copyWith(description: event.description);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onRentChanged(
    RentChanged event,
    Emitter<AddListingState> emit,
  ) async {
    final rent = double.tryParse(event.rent) ?? 0;
    _currentFormData = _currentFormData.copyWith(monthlyRent: rent);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onRoomTypeChanged(
    RoomTypeChanged event,
    Emitter<AddListingState> emit,
  ) async {
    _currentFormData = _currentFormData.copyWith(roomType: event.roomType);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onAvailableSlotsChanged(
    AvailableSlotsChanged event,
    Emitter<AddListingState> emit,
  ) async {
    final slots = int.tryParse(event.slots) ?? 0;
    _currentFormData = _currentFormData.copyWith(availableSlots: slots);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onTotalSlotsChanged(
    TotalSlotsChanged event,
    Emitter<AddListingState> emit,
  ) async {
    final slots = int.tryParse(event.slots) ?? 0;
    _currentFormData = _currentFormData.copyWith(totalSlots: slots);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onGenderPreferenceChanged(
    GenderPreferenceChanged event,
    Emitter<AddListingState> emit,
  ) async {
    _currentFormData = _currentFormData.copyWith(genderPreference: event.preference);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onAmenityToggled(
    AmenityToggled event,
    Emitter<AddListingState> emit,
  ) async {
    switch (event.amenity) {
      case 'wifi':
        _currentFormData = _currentFormData.copyWith(wifiAvailable: event.value);
        break;
      case 'privateCR':
        _currentFormData = _currentFormData.copyWith(privateCR: event.value);
        break;
      case 'sharedCR':
        _currentFormData = _currentFormData.copyWith(sharedCR: event.value);
        break;
      case 'petFriendly':
        _currentFormData = _currentFormData.copyWith(petFriendly: event.value);
        break;
    }
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onPhotosAdded(
    PhotosAdded event,
    Emitter<AddListingState> emit,
  ) async {
    final updatedPhotos = [..._currentFormData.photoUrls, ...event.photoPaths];
    _currentFormData = _currentFormData.copyWith(photoUrls: updatedPhotos);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onPhotoRemoved(
    PhotoRemoved event,
    Emitter<AddListingState> emit,
  ) async {
    final updatedPhotos = List<String>.from(_currentFormData.photoUrls);
    updatedPhotos.removeAt(event.index);
    _currentFormData = _currentFormData.copyWith(photoUrls: updatedPhotos);
    emit(AddListingFormUpdated(_currentFormData));
  }

  Future<void> _onListingSubmitted(
    ListingSubmitted event,
    Emitter<AddListingState> emit,
  ) async {
    try {
      emit(const AddListingLoading());

      // Validate form
      final validationError = _currentFormData.validate();
      if (validationError != null) {
        emit(AddListingError(validationError));
        return;
      }

      // Submit to repository
      final listingId = await _listingRepository.addListing(
        _currentFormData.toMap(),
        _currentFormData.photoUrls,
      );

      emit(AddListingSuccess(listingId));
    } catch (e) {
      emit(AddListingError(e.toString()));
    }
  }
}
