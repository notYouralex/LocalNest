# Quick Reference - Using Core Components

## Filter Components

### 1. Using Advanced Filter Modal (Recommended)

```dart
import 'package:local_nest/core/widgets/filter/filter.dart';

// In your widget:
void _showFilterModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AdvancedFilterModal(
      minPrice: 500,           // Optional: prefill values
      maxPrice: 2000,
      roomType: 'solo',
      capacity: '2+',
      onApply: (filterData) {
        // filterData contains:
        // {
        //   'minPrice': 500.0,
        //   'maxPrice': 2000.0,
        //   'roomType': 'solo',
        //   'capacity': '2+'
        // }
        _applyFilters(filterData);
      },
    ),
  );
}
```

### 2. Using Individual Filter Components

```dart
import 'package:local_nest/core/widgets/filter/filter.dart';

// FilterChip
FilterChip(
  label: 'Solo',
  isSelected: _selectedRoomType == 'solo',
  onTap: () => setState(() => _selectedRoomType = 'solo'),
)

// PriceInput
PriceInput(
  label: 'Minimum Price',
  controller: _minController,
  onChanged: (value) => print('Min: $value'),
  error: _minError,
)
```

---

## State Components

### 1. Loading State

```dart
import 'package:local_nest/core/widgets/states/states.dart';

// Simple loading
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    if (state is LoadingState) {
      return LoadingStateWidget(
        message: 'Loading listings...',
      );
    }
    // ...
  },
);

// In a container for consistent sizing
Container(
  height: 200,
  child: LoadingStateWidget(
    message: 'Searching...',
  ),
)
```

### 2. Error State

```dart
// With retry button
ErrorStateWidget(
  message: 'Failed to load listings',
  onRetry: () {
    // Retry logic here
    _listingBloc.add(FetchListingsEvent());
  },
)

// Without retry
ErrorStateWidget(
  message: 'Network error occurred',
)
```

### 3. Empty State

```dart
// Full empty state
EmptyStateWidget(
  title: 'No listings found',
  subtitle: 'Try adjusting your filters',
  icon: Icons.search_off,
  onRetry: () {
    // Refresh or modify search
  },
)

// Minimal empty state
EmptyStateWidget(
  title: 'No results',
)
```

---

## Complete Example - Search Page

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_nest/core/widgets/widgets.dart';

class MySearchPage extends StatefulWidget {
  @override
  State<MySearchPage> createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AdvancedFilterModal(
        onApply: (filters) {
          // Apply filters
          _applyFilters(filters);
        },
      ),
    );
  }

  void _applyFilters(Map<String, dynamic> filters) {
    final minPrice = filters['minPrice'] as double?;
    final maxPrice = filters['maxPrice'] as double?;
    final roomType = filters['roomType'] as String;
    final capacity = filters['capacity'] as String;

    print('Filters: min=$minPrice, max=$maxPrice, room=$roomType, capacity=$capacity');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        // State handlers using core components
        if (state is LoadingState) {
          return LoadingStateWidget(message: 'Searching...');
        }

        if (state is ErrorState) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () {
              // Retry logic
            },
          );
        }

        if (state is EmptyState) {
          return EmptyStateWidget(
            title: 'No listings found',
            icon: Icons.search_off,
          );
        }

        if (state is LoadedState) {
          return ListView(
            children: state.listings
                .map((listing) => ListingCard(listing: listing))
                .toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
```

---

## Complete Example - Home Page

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_nest/core/widgets/widgets.dart';
import 'package:local_nest/features/home/widgets/home_filter_modal.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _handleFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => HomeFilterModal(
        onApplyFilters: (filters) {
          // Handle filter application
          print('Applied filters: $filters');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListingBloc, ListingState>(
      builder: (context, state) {
        if (state is ListingLoadingState) {
          return Container(
            height: 300,
            child: LoadingStateWidget(message: 'Loading listings...'),
          );
        }

        if (state is ListingErrorState) {
          return Container(
            height: 300,
            child: ErrorStateWidget(
              message: state.message,
              onRetry: () {
                context.read<ListingBloc>().add(RefreshListingsEvent());
              },
            ),
          );
        }

        if (state is ListingLoadedState && state.listings.isEmpty) {
          return Container(
            height: 300,
            child: EmptyStateWidget(
              title: 'No listings available',
              icon: Icons.home_work_outlined,
            ),
          );
        }

        return Scaffold(
          body: GridView.builder(
            // Your grid implementation
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _handleFilter,
            child: Icon(Icons.filter_list),
          ),
        );
      },
    );
  }
}
```

---

## Import Patterns

### Barrel Import (Recommended)
```dart
import 'package:local_nest/core/widgets/widgets.dart';

// All components available:
// - AdvancedFilterModal
// - FilterChip
// - PriceInput
// - LoadingStateWidget
// - ErrorStateWidget
// - EmptyStateWidget
```

### Direct Imports
```dart
// Filter components
import 'package:local_nest/core/widgets/filter/advanced_filter_modal.dart';
import 'package:local_nest/core/widgets/filter/filter_chip.dart';
import 'package:local_nest/core/widgets/filter/price_input.dart';

// State components
import 'package:local_nest/core/widgets/states/loading_state.dart';
import 'package:local_nest/core/widgets/states/error_state.dart';
import 'package:local_nest/core/widgets/states/empty_state.dart';
```

### Filter Barrel Import
```dart
import 'package:local_nest/core/widgets/filter/filter.dart';

// All filter components available:
// - AdvancedFilterModal
// - FilterChip
// - PriceInput
```

### State Barrel Import
```dart
import 'package:local_nest/core/widgets/states/states.dart';

// All state components available:
// - LoadingStateWidget
// - ErrorStateWidget
// - EmptyStateWidget
```

---

## Customization Guide

### Custom Loading Message
```dart
LoadingStateWidget(
  message: 'Searching for your perfect home...',
  height: 400,
)
```

### Custom Error with Retry
```dart
ErrorStateWidget(
  message: 'Oops! Something went wrong. Please try again.',
  onRetry: () {
    // Your retry logic
    myBloc.add(RefetchEvent());
  },
  height: 300,
)
```

### Custom Empty State
```dart
EmptyStateWidget(
  title: 'No Listings Found',
  subtitle: 'Try adjusting your search criteria',
  icon: Icons.apartment,
  onRetry: () {
    // Reset filters or search
    resetFilters();
  },
  height: 400,
)
```

### Styled Filter Modal
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => AdvancedFilterModal(
    minPrice: currentMin,
    maxPrice: currentMax,
    roomType: selectedRoom,
    capacity: selectedCapacity,
    onApply: (filters) {
      // Process filters
      applyFilters(filters);
    },
  ),
)
```

---

## Common Patterns

### Pagination with Loading
```dart
BlocBuilder<SearchBloc, SearchState>(
  builder: (context, state) {
    if (state is SearchLoadingState) {
      return LoadingStateWidget(message: 'Loading more results...');
    }

    if (state is SearchSuccessState) {
      return ListView(
        children: [
          ...state.listings,
          if (state.hasMoreResults)
            LoadingStateWidget(message: 'Fetching more...'),
        ],
      );
    }

    // Other states
  },
)
```

### Error Recovery
```dart
BlocBuilder<ListingBloc, ListingState>(
  builder: (context, state) {
    if (state is ErrorState) {
      return Column(
        children: [
          ErrorStateWidget(
            message: state.message,
            onRetry: () => _retryFetch(),
          ),
          SizedBox(height: 16),
          Text('Error details: ${state.code}'),
        ],
      );
    }

    // Success state
  },
)
```

### Filter Chain (Multiple Filters)
```dart
void _applyMultipleFilters(Map<String, dynamic> filters) {
  final minPrice = filters['minPrice'] as double?;
  final maxPrice = filters['maxPrice'] as double?;
  final roomType = filters['roomType'] as String;
  final capacity = filters['capacity'] as String;

  myBloc.add(
    FilterListingsEvent(
      minPrice: minPrice,
      maxPrice: maxPrice,
      roomType: roomType,
      capacity: capacity,
    ),
  );
}
```

---

## Troubleshooting

### Issue: Component not showing
**Solution:** Ensure it's wrapped in proper context (BlocBuilder, Container with height, etc.)

```dart
// ❌ Wrong - no constraints
LoadingStateWidget()

// ✅ Right - has constraints
SizedBox(
  height: 200,
  child: LoadingStateWidget(),
)

// ✅ Right - in BlocBuilder
BlocBuilder(
  builder: (context, state) {
    if (state is Loading) return LoadingStateWidget();
  },
)
```

### Issue: Filter modal not closing
**Solution:** Ensure `Navigator.pop(context)` is called after `onApply`

```dart
// ✅ Correct - modal auto-closes on apply
AdvancedFilterModal(
  onApply: (filters) {
    _applyFilters(filters);
    // Modal automatically closes via Navigator.pop()
  },
)
```

### Issue: Price validation errors
**Solution:** Ensure numbers are parsed correctly

```dart
// ✅ In your onApply handler:
void _applyFilters(Map<String, dynamic> filters) {
  final minPrice = filters['minPrice'] as double?;  // Already double
  final maxPrice = filters['maxPrice'] as double?;  // Already double
  
  if (minPrice != null && minPrice < 0) return;     // Validation
  if (maxPrice != null && maxPrice < minPrice) return;
}
```

---

## Best Practices

1. **Always provide height constraints** for state widgets in non-BlocBuilder contexts
2. **Use barrel imports** for cleaner code (`import '...widgets.dart'`)
3. **Customize messages** for context-specific messaging
4. **Chain error handling** with retry callbacks
5. **Test BLoC events** separately from UI components
6. **Reuse components** across features - don't create duplicates
7. **Keep filter validation** in the core component, not in features
8. **Document custom filter handlers** in your features

---

## Files Location Quick Reference

```
Core Components:
├── Filter modal & chips
│   └── lib/core/widgets/filter/
│       ├── advanced_filter_modal.dart     (Main modal)
│       ├── filter_chip.dart                (Reusable chip)
│       ├── price_input.dart                (Price input)
│       └── filter.dart                     (Barrel export)
│
└── State components
    └── lib/core/widgets/states/
        ├── loading_state.dart              (Loading indicator)
        ├── error_state.dart                (Error display)
        ├── empty_state.dart                (Empty state)
        └── states.dart                     (Barrel export)

Feature Wrappers:
├── Search Feature
│   └── lib/features/search/widgets/
│       └── filter_modal.dart               (Search wrapper)
│
└── Home Feature
    └── lib/features/home/widgets/
        └── home_filter_modal.dart          (Home wrapper)
```

---

Happy coding! 🚀 These components are production-ready and fully tested.
