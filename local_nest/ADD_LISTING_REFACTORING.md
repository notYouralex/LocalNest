# Add Listing Feature - Clean Architecture Refactoring

## Overview

The Add Listing feature has been completely refactored to follow **Clean Architecture** and **SOLID Principles**. This document explains the structure and design decisions.

---

## Architecture Layers

### 1. **Data Layer** (`repositories/`)
Responsible for all data persistence and external service interactions.

**File:** `listing_repository.dart`

**Components:**
- **Abstract Class**: `ListingRepository` - Defines contract for data operations
- **Implementation**: `ListingRepositoryImpl` - Actual implementation with Firebase integration points
- **Methods**:
  - `addListing(Map<String, dynamic> listingData, List<String> imagePaths)` - Save new listing
  - `updateListing(String listingId, Map<String, dynamic> listingData)` - Update existing listing
  - `deleteListing(String listingId)` - Remove listing

**SOLID Principles Applied:**
- **Dependency Inversion**: BLoC depends on abstract `ListingRepository`, not concrete implementation
- **Interface Segregation**: Repository only exposes necessary methods
- **Single Responsibility**: Only handles data persistence

**Firebase Integration Points** (marked as TODO):
- Firestore document creation/update
- Cloud Storage image upload
- Error handling and retry logic

---

### 2. **Service Layer** (`services/`)
Contains reusable business logic and validations.

#### **Form Validation Service**
**File:** `form_validation_service.dart`

**Single Responsibility Principle:**
- Encapsulates ALL form validation logic
- Provides both field-level and form-level validation
- Easy to test independently

**Methods:**
- `validatePropertyName(String name)` - 3-100 characters
- `validateAddress(String address)` - Non-empty, meaningful
- `validateCity(String city)` - Standard city validation
- `validateDescription(String desc)` - 20-1000 characters
- `validateRent(double rent)` - ₱1,000 - ₱1,000,000
- `validateSlots(int available, int total)` - Proper slot relationships
- `validatePhotos(List<String> photos)` - 1-10 photos required
- `validateFormData(ListingFormData data)` - Complete form validation

**Benefits:**
- Centralized validation rules
- Consistent error messages
- Easy to modify validation rules globally
- Can be reused in other features

#### **Image Handling Service**
**File:** `image_handling_service.dart`

**Single Responsibility Principle:**
- Handles ONLY image-related operations
- Manages image picking and validation
- Enforces file constraints (size, format, count)

**Methods:**
- `pickImages()` - Launch image picker, return file paths
- `validateImageFile(String filePath)` - Validate extension (JPG/PNG)
- `canAddMorePhotos(int currentCount)` - Check 10-photo limit
- `getRemainingPhotoSlots(int currentCount)` - Calculate available slots

**Constants:**
```dart
static const int maxFileSize = 10 * 1024 * 1024; // 10MB
static const int maxPhotosCount = 10;
static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
```

**Benefits:**
- Separated from form logic
- Reusable in other features (profile avatar, gallery, etc.)
- Easy to swap image source (camera, gallery, cloud)

---

### 3. **Presentation Layer - State Management** (`bloc/`)

**File:** `add_listing_bloc.dart`

Implements **BLoC Pattern** for reactive state management.

#### **Events** (User Intentions)
- `PropertyNameChanged` - User updates property name
- `AddressChanged` - User updates address
- `CityChanged` - User updates city
- `DescriptionChanged` - User updates description
- `RentChanged` - User updates monthly rent
- `RoomTypeChanged` - User selects room type
- `AvailableSlotsChanged` - User updates available slots
- `TotalSlotsChanged` - User updates total slots
- `GenderPreferenceChanged` - User selects gender preference
- `AmenityToggled` - User toggles amenities
- `PhotosAdded` - User adds photos
- `PhotoRemoved` - User removes photo
- `ListingSubmitted` - User submits form

#### **States** (UI States)
- `AddListingInitial` - Initial state
- `AddListingFormUpdated` - Form updated with optional validation error
- `AddListingLoading` - Submission in progress
- `AddListingSuccess` - Listing created successfully
- `AddListingError` - Error occurred

**Key Features:**
- **Form State Management**: Maintains `ListingFormData` as current form state
- **Validation Integration**: Validates on submission, not on change (for better UX)
- **Error Handling**: Catches and emits appropriate error states
- **Dependency Injection**: Repository injected through constructor

**SOLID Principles:**
- **Single Responsibility**: Only manages Add Listing state
- **Open/Closed**: Can add new events/states without modifying existing code
- **Dependency Inversion**: Depends on abstract `ListingRepository`

---

### 4. **Presentation Layer - UI** (`pages/` and `widgets/`)

#### **Main Page**
**File:** `pages/add_listing_page.dart`

**Architecture:**
- **Stateless**: All state managed by BLoC
- **Clean**: Minimal logic, only UI composition
- **Composable**: Built from reusable sections
- **Lines**: ~100 (down from ~700 in monolithic version)

**Key Responsibilities:**
1. Provide BLoC to widget tree
2. Listen to BLoC state changes
3. Show success/error messages
4. Compose form sections
5. Handle submit button

#### **Form Section Widgets**

Each section is a **StatefulWidget** that:
- Manages its own TextEditingControllers
- Emits events to BLoC on user input
- Is **reusable** in other forms

**Sections:**

1. **BasicInfoSection** (`widgets/basic_info_section.dart`)
   - Property name input
   - Description textarea
   - Step indicator

2. **LocationSection** (`widgets/location_section.dart`)
   - Complete address input
   - City/Municipality input
   - Step indicator

3. **PricingCapacitySection** (`widgets/pricing_capacity_section.dart`)
   - Monthly rent input
   - Room type dropdown
   - Available slots input
   - Total slots input
   - Gender preference dropdown
   - Step indicator

4. **AmenitiesSection** (`widgets/amenities_section.dart`)
   - WiFi checkbox
   - Private CR checkbox
   - Shared CR checkbox
   - Pet Friendly checkbox
   - Step indicator

5. **PhotosSection** (`widgets/photos_section.dart`)
   - Image picker integration
   - Photo grid display
   - Photo removal
   - Remaining slots indicator
   - Step indicator

#### **Reusable Components**

1. **FormTextField** (`widgets/form_text_field.dart`)
   - Consistent text input styling
   - Built-in validation UI
   - Customizable for different input types
   - Reduces code duplication across sections

2. **SectionHeader** (`widgets/section_header.dart`)
   - Numbered step indicator
   - Title and description
   - Consistent styling across sections

---

## Data Model

**File:** `models/listing_form_model.dart`

```dart
class ListingFormData {
  final String propertyName;
  final String completeAddress;
  final String city;
  final String description;
  final double monthlyRent;
  final String roomType;
  final int availableSlots;
  final int totalSlots;
  final String genderPreference;
  final bool wifiAvailable;
  final bool privateCR;
  final bool sharedCR;
  final bool petFriendly;
  final List<String> photoUrls;
  
  // Methods:
  // - copyWith(): Immutable updates
  // - validate(): Form validation
  // - toMap(): Serialization for Firebase
}
```

**Design:**
- **Immutable**: Uses `copyWith()` for updates
- **Validatable**: Has `validate()` method
- **Serializable**: Has `toMap()` for persistence
- **Single Responsibility**: Only holds form data

---

## SOLID Principles Implementation

### 1. **Single Responsibility Principle (SRP)**
- ✅ `FormValidationService` - Only validation
- ✅ `ImageHandlingService` - Only image operations
- ✅ `ListingRepository` - Only data persistence
- ✅ `AddListingBloc` - Only state management
- ✅ Each widget - Single, focused purpose

### 2. **Open/Closed Principle (OCP)**
- ✅ Can add new form sections without modifying `AddListingPage`
- ✅ Can add new validations without modifying existing rules
- ✅ Can add new amenities without touching other code
- ✅ Can extend `ListingRepository` with new methods

### 3. **Liskov Substitution Principle (LSP)**
- ✅ `ListingRepositoryImpl` can be swapped with mock implementation for testing
- ✅ All events properly extend `AddListingEvent`
- ✅ All states properly extend `AddListingState`

### 4. **Interface Segregation Principle (ISP)**
- ✅ `ListingRepository` exposes only necessary methods
- ✅ Services expose only relevant methods
- ✅ BLoC doesn't depend on unnecessary dependencies

### 5. **Dependency Inversion Principle (DIP)**
- ✅ `AddListingBloc` depends on abstract `ListingRepository`
- ✅ Dependencies injected through constructors
- ✅ Easy to mock for testing
- ✅ Easy to switch implementations

---

## Code Metrics

### Before Refactoring
- **AddListingPage**: ~700 lines (monolithic)
- **Responsibilities**: 5 (UI, State, Validation, Image handling, Data)
- **Reusability**: Low (tight coupling)
- **Testability**: Poor (everything mixed together)

### After Refactoring
- **AddListingPage**: ~100 lines (composition only)
- **AddListingBloc**: ~250 lines (state management)
- **Form Sections**: ~60 lines each (focused)
- **Services**: ~100 lines total (reusable)
- **Responsibilities**: 1 each (single responsibility)
- **Reusability**: High (components can be used elsewhere)
- **Testability**: Excellent (can test each layer independently)

---

## Testing Strategy

### Unit Tests
```dart
// Validation service
test('validatePropertyName returns error for short names');
test('validateRent returns error for invalid range');

// BLoC
test('PropertyNameChanged updates form state');
test('ListingSubmitted validates before submission');
```

### Widget Tests
```dart
// Form sections
testWidgets('BasicInfoSection renders text fields');
testWidgets('PhotosSection handles image selection');

// Components
testWidgets('FormTextField validates input');
testWidgets('SectionHeader displays correct step number');
```

### Integration Tests
```dart
// Full flow
testWidgets('User can complete and submit listing form');
testWidgets('Form validation prevents invalid submission');
```

---

## Future Improvements

### Phase 2: Firebase Integration
- [ ] Implement `addListing()` with Firestore write
- [ ] Implement image upload to Cloud Storage
- [ ] Add offline support with local caching
- [ ] Implement real-time progress updates

### Phase 3: Enhanced Features
- [ ] Map integration for location pinning
- [ ] Image cropping and compression
- [ ] Draft saving
- [ ] Multi-image upload with progress tracking
- [ ] Form auto-save on user blur

### Phase 4: Advanced Architecture
- [ ] Add Use Cases layer (repository pattern)
- [ ] Implement Data/Domain separation
- [ ] Add presentation mappers
- [ ] Implement error handling layer

---

## File Structure

```
lib/features/profile/
├── bloc/
│   └── add_listing_bloc.dart          # State management
├── models/
│   └── listing_form_model.dart        # Data model
├── repositories/
│   └── listing_repository.dart        # Data access layer
├── services/
│   ├── form_validation_service.dart   # Business logic
│   └── image_handling_service.dart    # Image operations
├── pages/
│   └── add_listing_page.dart          # Main page (100 lines)
└── widgets/
    ├── add_listing_page.dart
    ├── basic_info_section.dart
    ├── location_section.dart
    ├── pricing_capacity_section.dart
    ├── amenities_section.dart
    ├── photos_section.dart
    ├── form_text_field.dart           # Reusable component
    └── section_header.dart            # Reusable component
```

---

## Summary

This refactoring demonstrates how to take a monolithic feature and structure it according to **Clean Architecture and SOLID Principles**:

1. **Clear layer separation** - Data, Service, Presentation
2. **Single responsibility** - Each class has one reason to change
3. **Dependency injection** - Loose coupling, easy testing
4. **Reusable components** - Can be used in other features
5. **Maintainability** - Easy to understand, modify, and extend
6. **Testability** - Each layer can be tested independently

The result is more **maintainable**, **scalable**, and **professional** code that's easier to test and modify.
