# Profile Pages - Clean Architecture Analysis & Improvement Plan

## Current State Assessment

### 📊 Code Metrics
| File | Size | Build Methods | Issues |
|------|------|---|---|
| `profile_page.dart` | 590+ lines | 5 | Large page class, mixed logic & UI |
| `manage_listings_page.dart` | 780+ lines | 7 | Too many responsibilities, complex state |
| `edit_profile_page.dart` | 348 lines | 4 | Widget building logic mixed with form logic |

---

## 🔴 Critical Issues (Spaghetti Code Patterns)

### 1. **Massive Page Classes (God Objects)**
**Profile Page Problems:**
- 590+ lines in single file
- Mix of: state management, UI building, business logic, data loading, event handling
- 5 nested `_build*` methods inside the page

**Manage Listings Page:**
- 780+ lines - even larger
- 7 builder methods
- Complex listing manipulation mixed with UI rendering
- Stats calculation mixed with page logic

**Result:** Hard to test, debug, and maintain. Single file change requires understanding entire page logic.

---

### 2. **Lack of Separation of Concerns**

**Current Pattern (Bad):**
```dart
class ProfilePage extends StatefulWidget {
  // State management
  late UserProfile _userProfile;
  bool _isLoading = true;
  
  // Business logic
  void _handleAccountTypeChange(String type) { ... }
  void _handleEditProfile() { ... }
  void _loadUserData() { ... }
  
  // UI Components
  Widget _buildStatsCards() { ... }
  Widget _buildMyListingsCard() { ... }
  
  // Complex build() with deeply nested widgets
}
```

**Issues:**
- State, logic, and UI all mixed
- Hard to track data flow
- Difficult to test business logic
- UI logic duplicated (see manage_listings with 7 builders)

---

### 3. **Widget Building Logic in Pages**
```dart
// ❌ BAD: 100+ lines of widget building in page
Widget _buildListingCard(Listing listing) {
  return Container(
    decoration: ...,
    child: Column(
      children: [
        Padding(
          child: Column(
            children: [
              Row(...),
              SizedBox(...),
              Text(...),
              // ... more 50+ lines
            ],
          ),
        ),
        Divider(...),
        // ... more nested widgets
      ],
    ),
  );
}
```

**Problems:**
- Hard to reuse components
- Can't style components separately
- Difficult to test individual widgets
- Makes page class huge

---

### 4. **Repeated Widget Patterns**
Both pages repeat similar patterns:
- Stats cards (profile) vs stat items (manage_listings)
- Menu items (profile) - could be extracted
- Button patterns (edit_profile) - hardcoded styles

**Result:** Code duplication, inconsistent styling, maintenance nightmare

---

### 5. **Business Logic Mixed with UI**
```dart
// ❌ BAD: Business logic in UI state
void _handleAccountTypeChange(String type) {
  setState(() => _userProfile = _userProfile.copyWith(accountType: type));
  // TODO: Update backend
}

void _handleSaveChanges() {
  if (_fullNameController.text.isEmpty) { // Validation
    // Show error
  }
  setState(() => _isLoading = true);
  // TODO: Call API
  // Update UI
}
```

**Problems:**
- Can't test logic without building UI
- Validation scattered throughout
- Backend calls mixed with state management
- No clear error handling strategy

---

### 6. **No Repository/Service Layer**
Currently:
```dart
// ❌ Direct data manipulation in page
_userProfile = UserProfile(...);
_listings = [Listing(...), ...];
await Future.delayed(...); // Mock delay

// TODO: Replace with actual Firebase call
```

**Problems:**
- Hard to swap Firebase with other backend
- No abstraction for data sources
- Business logic depends on page implementation
- Can't cache or retry failed requests

---

### 7. **Form Handling Issues (EditProfile)**
```dart
// ❌ Multiple text controllers, no form state
late TextEditingController _fullNameController;
late TextEditingController _emailController;
late TextEditingController _phoneController;

// Validation scattered in handler
if (_fullNameController.text.isEmpty) { ... }

// Manual dispose required for each
@override
void dispose() {
  _fullNameController.dispose();
  _emailController.dispose();
  _phoneController.dispose();
  super.dispose();
}
```

**Problems:**
- Easy to leak controllers
- No unified form validation
- Hard to manage multiple fields
- Boilerplate for each new field

---

### 8. **No Error Handling Strategy**
```dart
try {
  // Load data
} catch (e) {
  setState(() {
    _errorMessage = 'Failed to load profile: $e';
  });
}
```

**Problems:**
- String-based errors (not typed)
- No error recovery strategies
- UI errors mixed with business errors
- No retry mechanisms

---

## 🎯 Improvement Plan - Clean Architecture

### Phase 1: Extract Repositories (Data Layer)
**Create:** `lib/features/profile/data/repositories/`

```
profile/data/
├── repositories/
│   ├── user_repository.dart (interface)
│   ├── user_repository_impl.dart (Firebase)
│   ├── listings_repository.dart
│   └── listings_repository_impl.dart
└── datasources/
    ├── user_local_datasource.dart
    └── user_remote_datasource.dart
```

**Benefits:**
- ✅ Decouple from Firebase
- ✅ Enable testing with mocks
- ✅ Support offline caching
- ✅ Centralized error handling

---

### Phase 2: Create Service/UseCase Layer
**Create:** `lib/features/profile/domain/`

```
profile/domain/
├── usecases/
│   ├── get_user_profile_usecase.dart
│   ├── update_user_profile_usecase.dart
│   ├── get_listings_usecase.dart
│   ├── update_listing_status_usecase.dart
│   └── delete_listing_usecase.dart
├── entities/
│   └── [domain models]
└── repositories/
    └── [abstract interfaces]
```

**Benefits:**
- ✅ Single responsibility (one usecase = one action)
- ✅ Testable business logic
- ✅ Clear data flow
- ✅ Centralized validation

---

### Phase 3: Extract Reusable Components
**Create:** `lib/features/profile/presentation/widgets/`

```
profile/presentation/widgets/
├── stat_card.dart (replaces _buildStatCard)
├── listing_card.dart (replaces _buildListingCard)
├── menu_item.dart (replaces _buildMenuItem)
├── detail_column.dart (replaces _buildDetailColumn)
├── action_button.dart (replaces _buildActionButton)
├── add_listing_button.dart
└── header_bar.dart
```

**Benefits:**
- ✅ Reusable across pages
- ✅ Consistent styling
- ✅ Easy to theme
- ✅ Testable UI components

---

### Phase 4: Use State Management
**Create:** `lib/features/profile/presentation/bloc/` or `provider/`

```
profile/presentation/bloc/
├── profile_bloc.dart
│   ├── ProfileEvent (GetProfile, UpdateProfile, ChangeAccountType)
│   ├── ProfileState (Loading, Loaded, Error)
│   └── ProfileBloc
├── listings_bloc.dart
│   ├── ListingsEvent (GetListings, DeleteListing, ToggleStatus)
│   ├── ListingsState
│   └── ListingsBloc
└── edit_profile_bloc.dart
```

**Benefits:**
- ✅ Clear state management
- ✅ Predictable state flow
- ✅ Decoupled from UI
- ✅ Testable state transitions
- ✅ Built-in error handling

---

### Phase 5: Refactor Pages (Presentation Layer)
**Simplified Pages:**

```
profile/presentation/pages/
├── profile_page.dart (now 150-200 lines)
├── manage_listings_page.dart (now 200-250 lines)
└── edit_profile_page.dart (now 100-150 lines)
```

**Each page will:**
- ✅ Depend on bloc/provider
- ✅ Render widgets only (no logic)
- ✅ Listen to state changes
- ✅ Dispatch events for user actions
- ✅ No business logic

---

## 📋 Concrete Refactoring Roadmap

### Step 1: Extract StatCard Widget (5 min)
```dart
// NEW FILE: lib/features/profile/presentation/widgets/stat_card.dart
class StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color backgroundColor;

  const StatCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... styling
    );
  }
}

// IN profile_page.dart - before
Widget _buildStatCard({...}) {
  return Container(...);
}

// IN profile_page.dart - after
StatCard(count: 5, label: 'Favorites', ...)
```

---

### Step 2: Extract ListingCard Widget (10 min)
```dart
// NEW FILE: lib/features/profile/presentation/widgets/listing_card.dart
class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ListingCard({
    required this.listing,
    required this.onActivate,
    // ...
  });

  @override
  Widget build(BuildContext context) {
    // Now 100+ lines of clean widget code
  }
}

// IN manage_listings_page.dart - after refactor
ListingCard(
  listing: listing,
  onActivate: () => _handleActivateListing(listing.id),
  onDeactivate: () => _handleDeactivateListing(listing.id),
  // ...
)
```

---

### Step 3: Extract ProfileBloc (20 min)
```dart
// NEW FILE: lib/features/profile/presentation/bloc/profile_bloc.dart
class ProfileEvent extends Equatable {}
class GetUserProfile extends ProfileEvent {}
class UpdateAccountType extends ProfileEvent {
  final String type;
  UpdateAccountType(this.type);
}

class ProfileState extends Equatable {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserProfile user;
  final NotificationSettings settings;
  final RenterStats stats;
  ProfileLoaded(this.user, this.settings, this.stats);
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc(this.userRepository) : super(ProfileLoading()) {
    on<GetUserProfile>(_onGetProfile);
    on<UpdateAccountType>(_onUpdateAccountType);
  }

  Future<void> _onGetProfile(GetUserProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await userRepository.getUserProfile();
      emit(ProfileLoaded(user, ...));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
```

---

### Step 4: Simplify ProfilePage (100+ lines → 150 lines)
```dart
// NEW FILE: lib/features/profile/presentation/pages/profile_page_refactored.dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const LoadingWidget();
          }
          
          if (state is ProfileError) {
            return ErrorWidget(message: state.message);
          }
          
          if (state is ProfileLoaded) {
            return _buildContent(context, state);
          }
          
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileLoaded state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeader(user: state.user),
          AccountTypeSection(
            selectedType: state.user.accountType,
            onTypeChanged: (type) {
              context.read<ProfileBloc>().add(UpdateAccountType(type));
            },
          ),
          if (state.user.accountType == 'renter')
            StatsSection(stats: state.stats)
          else
            MyListingsCard(onTap: () => context.push('/manage-listings')),
          // ... rest of widgets
        ],
      ),
    );
  }
}
```

---

## 🚀 Benefits After Refactoring

| Aspect | Before | After |
|--------|--------|-------|
| **File Size** | 590+ lines | 150-200 lines |
| **Testability** | ❌ Hard | ✅ Easy (bloc + services) |
| **Reusability** | ❌ Low (mixed into page) | ✅ High (extracted widgets) |
| **Maintainability** | ❌ Hard (god object) | ✅ Easy (SRP) |
| **Error Handling** | ❌ String-based | ✅ Typed exceptions |
| **Data Source Swap** | ❌ Hard (Firebase hardcoded) | ✅ Easy (repository pattern) |
| **Code Duplication** | ❌ High (7+ build methods) | ✅ Low (reusable widgets) |
| **Dev Velocity** | ❌ Slow (understand whole page) | ✅ Fast (focus on one area) |

---

## ⚡ Quick Wins (Do First)

### Week 1: Extract Widgets
1. `StatCard` ← 5 min
2. `ListingCard` ← 10 min
3. `MenuItem` ← 5 min
4. `DetailColumn` ← 3 min
5. `ActionButton` ← 3 min

**Time:** ~30 min
**Result:** Reduce profile_page to 400 lines, manage_listings to 600 lines

### Week 2: Add Repository Layer
1. `UserRepository` (interface)
2. `UserRepositoryImpl` (Firebase)
3. `ListingsRepository` (interface)
4. `ListingsRepositoryImpl` (Firebase)

**Time:** ~2 hours
**Result:** Decoupled data layer, easy to test

### Week 3: Add Bloc Layer
1. `ProfileBloc` for user profile
2. `ListingsBloc` for listings management

**Time:** ~3 hours
**Result:** Clear state management, testable business logic

### Week 4: Simplify Pages
1. Rewrite `ProfilePage` with bloc
2. Rewrite `ManageListingsPage` with bloc
3. Rewrite `EditProfilePage` with form bloc

**Time:** ~4 hours
**Result:** Clean pages, easy to understand

---

## 📚 Architecture Overview (After Refactoring)

```
DATA FLOW:
UI (Page) 
  ↓ (Dispatches Event)
Bloc 
  ↓ (Calls UseCase)
UseCase/Service
  ↓ (Calls Repository)
Repository
  ↓ (Calls DataSource)
DataSource (Firebase/Local)
  ↓ (Returns Data)
Entity/Model
  ↓ (Emits State)
Bloc
  ↓ (Rebuilds UI)
Widget Tree
```

---

## ✅ Next Steps

1. **Review this analysis** with team
2. **Start with Week 1 quick wins** (extract widgets)
3. **Move to repositories** (decouple data layer)
4. **Add bloc/provider** (state management)
5. **Simplify pages** (presentation layer only)

Would you like me to **implement any of these phases**? I recommend starting with:
- **Phase 1:** Extract reusable widgets (biggest immediate impact)
- **Phase 2:** Add repository layer (enables testing)
- **Phase 3:** Add bloc (makes state predictable)

Let me know which phase to implement first! 🚀
