# Profile Pages - Current vs Desired Architecture

## 🔴 CURRENT STATE: Spaghetti Code

```
ProfilePage (590 lines)
├─ State Properties
│  ├─ late UserProfile _userProfile
│  ├─ late NotificationSettings _notificationSettings
│  ├─ late RenterStats _renterStats
│  ├─ bool _isLoading
│  └─ String? _errorMessage
│
├─ Lifecycle Methods
│  ├─ initState() → calls _initializeData()
│  └─ _initializeData() → initializes all data
│
├─ Event Handlers (Mixed Logic + State)
│  ├─ _handleAccountTypeChange() ← Should be in Bloc
│  ├─ _handleEditProfile() ← Should be in Bloc
│  ├─ _handleLogout() ← Should be in Bloc
│  ├─ _handleSavedSearches() ← UI navigation
│  ├─ _handlePrivacySafety() ← UI navigation
│  └─ _handleHelpSupport() ← UI navigation
│
└─ Widget Builders (Should be Separate Widgets)
   ├─ _buildStatsCards()
   │  └─ _buildStatCard() ← Repeated pattern
   ├─ _buildMyListingsCard()
   ├─ _buildMenuItemWithDivider()
   │  └─ _buildMenuItem()
   └─ build() → 200+ lines of nested widgets

╔══════════════════════════════════════════════════════════╗
║ PROBLEMS:                                                ║
║ ❌ Can't test business logic (tied to Flutter)          ║
║ ❌ Can't reuse widgets (embedded in page)                ║
║ ❌ Hard to navigate code (single 590-line file)          ║
║ ❌ Easy to introduce bugs (complex build method)         ║
║ ❌ State management scattered (setState everywhere)      ║
║ ❌ Can't swap data sources (hardcoded logic)             ║
╚══════════════════════════════════════════════════════════╝
```

---

## 🟢 DESIRED STATE: Clean Architecture

```
presentation/
│
├─ pages/
│  └─ profile_page.dart (150 lines)
│     ├─ BlocBuilder<ProfileBloc, ProfileState>
│     ├─ Render widgets (No logic)
│     └─ Dispatch events (BlocBuilder)
│
├─ bloc/
│  ├─ profile_bloc.dart
│  │  ├─ ProfileEvent
│  │  │  ├─ GetUserProfile
│  │  │  ├─ UpdateAccountType
│  │  │  ├─ UpdateProfile
│  │  │  └─ Logout
│  │  │
│  │  ├─ ProfileState
│  │  │  ├─ ProfileLoading
│  │  │  ├─ ProfileLoaded
│  │  │  ├─ ProfileError
│  │  │  └─ ProfileUpdated
│  │  │
│  │  └─ ProfileBloc
│  │     ├─ _onGetProfile() ← Calls UseCase
│  │     ├─ _onUpdateAccountType() ← Calls UseCase
│  │     └─ _onUpdateProfile() ← Calls UseCase
│  │
│  └─ listings_bloc.dart (similar structure)
│
└─ widgets/
   ├─ stat_card.dart (Reusable component)
   ├─ listing_card.dart (Reusable component)
   ├─ menu_item.dart (Reusable component)
   ├─ action_button.dart (Reusable component)
   ├─ detail_column.dart (Reusable component)
   └─ add_listing_button.dart (Reusable component)

domain/
│
├─ usecases/
│  ├─ get_user_profile_usecase.dart
│  │  ├─ Call repository
│  │  └─ Return Result<UserProfile>
│  │
│  ├─ update_user_profile_usecase.dart
│  │  ├─ Validate input
│  │  ├─ Call repository
│  │  └─ Return Result<void>
│  │
│  ├─ get_listings_usecase.dart
│  │  ├─ Call repository
│  │  └─ Return Result<List<Listing>>
│  │
│  └─ [other usecases...]
│
├─ entities/
│  ├─ user_profile.dart
│  ├─ notification_settings.dart
│  ├─ renter_stats.dart
│  └─ listing.dart
│
└─ repositories/ (Interfaces only)
   ├─ user_repository.dart (abstract)
   └─ listings_repository.dart (abstract)

data/
│
├─ repositories/ (Implementations)
│  ├─ user_repository_impl.dart
│  │  └─ Implements UserRepository
│  │     ├─ Calls remote datasource (Firebase)
│  │     ├─ Caches in local datasource
│  │     └─ Returns domain Entity
│  │
│  └─ listings_repository_impl.dart
│
└─ datasources/
   ├─ user_remote_datasource.dart (Firebase)
   ├─ user_local_datasource.dart (Hive/SQLite)
   ├─ listings_remote_datasource.dart (Firebase)
   └─ listings_local_datasource.dart (Hive/SQLite)

╔══════════════════════════════════════════════════════════╗
║ BENEFITS:                                                ║
║ ✅ Testable: Mock repositories, test bloc separately    ║
║ ✅ Reusable: Shared widgets, services, blocs            ║
║ ✅ Maintainable: Each file has single responsibility    ║
║ ✅ Flexible: Swap Firebase for any backend              ║
║ ✅ Scalable: Easy to add new features                   ║
║ ✅ Predictable: Clear data flow (unidirectional)        ║
╚══════════════════════════════════════════════════════════╝
```

---

## 📊 Data Flow Comparison

### BEFORE: Chaotic Flow
```
User Action
    ↓
PageMethod (e.g., _handleAccountTypeChange)
    ↓ (calls setState)
State Update (_userProfile = ...)
    ↓ (triggers rebuild)
build()
    ├─ Check loading state
    ├─ Build widgets manually
    └─ Call _build methods
    
Problem: Multiple sources of truth, hard to trace
```

### AFTER: Clean Unidirectional Flow
```
User Action (Tap Button)
    ↓
PageWidget (BlocListener)
    ├─ context.read<ProfileBloc>().add(UpdateProfile(...))
    ↓
ProfileBloc
    ├─ Map event to state change
    ├─ Call usecase
    ├─ Handle result
    └─ emit(ProfileUpdated(...))
    ↓
PageWidget (BlocBuilder)
    ├─ Rebuild with new state
    └─ Render widgets
    
Benefit: Single source of truth, easy to trace & test
```

---

## 🔄 File Reorganization

### BEFORE: Everything in Pages
```
profile/pages/
├─ profile_page.dart (590 lines) ← God object
├─ manage_listings_page.dart (780 lines) ← God object
└─ edit_profile_page.dart (348 lines) ← God object

Total: 1718 lines in 3 files, all mixed concerns
```

### AFTER: Organized by Layer
```
profile/
├─ presentation/
│  ├─ pages/
│  │  ├─ profile_page.dart (150 lines) ← Render only
│  │  ├─ manage_listings_page.dart (180 lines) ← Render only
│  │  └─ edit_profile_page.dart (120 lines) ← Render only
│  │
│  ├─ bloc/
│  │  ├─ profile_bloc.dart (100 lines)
│  │  ├─ listings_bloc.dart (120 lines)
│  │  └─ edit_profile_bloc.dart (80 lines)
│  │
│  └─ widgets/
│     ├─ stat_card.dart (50 lines)
│     ├─ listing_card.dart (150 lines) ← Extracted from page
│     ├─ menu_item.dart (30 lines)
│     ├─ action_button.dart (35 lines)
│     ├─ detail_column.dart (25 lines)
│     └─ add_listing_button.dart (25 lines)
│
├─ domain/
│  ├─ usecases/
│  │  ├─ get_user_profile_usecase.dart (30 lines)
│  │  ├─ update_user_profile_usecase.dart (35 lines)
│  │  └─ [other usecases...]
│  │
│  ├─ entities/
│  │  └─ [models]
│  │
│  └─ repositories/
│     └─ [interfaces]
│
└─ data/
   ├─ repositories/
   │  └─ [implementations]
   │
   └─ datasources/
      └─ [Firebase, local storage]

Total: ~2000 lines but ORGANIZED, TESTABLE, MAINTAINABLE
Each file < 150 lines, single responsibility
```

---

## 🎯 Widget Extraction Example

### BEFORE: _buildStatCard in ProfilePage
```dart
// Inside profile_page.dart (line 242)
Widget _buildStatCard({
  required int count,
  required String label,
  required IconData icon,
  required Color backgroundColor,
}) {
  return Container(
    padding: const EdgeInsets.all(ProfileConstants.cardSpacing),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(
        color: AppColors.border,
        width: ProfileConstants.borderWidth,
      ),
      borderRadius: BorderRadius.circular(ProfileConstants.cardBorderRadius),
    ),
    child: Column(
      children: [
        Container(
          width: ProfileConstants.largeIconSize * 2,
          height: ProfileConstants.largeIconSize * 2,
          decoration: BoxDecoration(
            color: backgroundColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: ProfileConstants.mediumIconSize,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          count.toString(),
          style: AppTextStyles.heading2.copyWith(
            fontSize: ProfileConstants.largeFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
```

### AFTER: Separate StatCard Widget
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
      padding: const EdgeInsets.all(ProfileConstants.cardSpacing),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.border,
          width: ProfileConstants.borderWidth,
        ),
        borderRadius: BorderRadius.circular(ProfileConstants.cardBorderRadius),
      ),
      child: Column(
        children: [
          Container(
            width: ProfileConstants.largeIconSize * 2,
            height: ProfileConstants.largeIconSize * 2,
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: ProfileConstants.mediumIconSize,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            count.toString(),
            style: AppTextStyles.heading2.copyWith(
              fontSize: ProfileConstants.largeFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// In profile_page.dart - MUCH CLEANER
StatCard(
  count: 5,
  label: 'Favorites',
  icon: Icons.favorite,
  backgroundColor: AppColors.statCardFavoritesBackground,
)
```

**Benefits:**
- ✅ Reusable (use in dashboard, stats page, etc)
- ✅ Testable (unit test the widget)
- ✅ Cleaner (removed 50 lines from profile_page)
- ✅ Themeable (change color scheme in one place)
- ✅ Composable (combine with other widgets)

---

## 📋 Migration Checklist

- [ ] Phase 1: Extract Widgets (30 min)
  - [ ] StatCard.dart
  - [ ] ListingCard.dart
  - [ ] MenuItem.dart
  - [ ] ActionButton.dart
  - [ ] DetailColumn.dart

- [ ] Phase 2: Repository Layer (2 hours)
  - [ ] Create interfaces (UserRepository, ListingsRepository)
  - [ ] Implement Firebase versions
  - [ ] Add dependency injection

- [ ] Phase 3: Bloc Layer (3 hours)
  - [ ] ProfileBloc
  - [ ] ListingsBloc
  - [ ] EditProfileBloc

- [ ] Phase 4: Simplify Pages (4 hours)
  - [ ] Refactor ProfilePage to use bloc
  - [ ] Refactor ManageListingsPage to use bloc
  - [ ] Refactor EditProfilePage with form validation

- [ ] Testing
  - [ ] Unit tests for blocs
  - [ ] Unit tests for usecases
  - [ ] Widget tests for components
  - [ ] Integration tests for pages

---

## 🚀 Ready to Start?

**Recommended first step:** Phase 1 - Extract Widgets
- **Time:** 30 minutes
- **Impact:** Huge (cleaner pages, reusable components)
- **Difficulty:** Easy (just move code to new files)

Would you like me to implement Phase 1 now? 🎯
