/// Constants for search feature
class SearchConstants {
  // Pagination
  static const int itemsPerPage = 10;
  static const double paginationThreshold = 200;

  // Debounce
  static const int searchDebounceMs = 600;

  // UI Spacing
  static const double headerHeight = 120;
  static const double searchBarHeight = 48;
  static const double horizontalPadding = 24;
  static const double verticalPadding = 24;
  static const double itemSpacing = 16;
  static const double borderRadius = 16;

  // Search Bar
  static const String searchHintText = 'Search location, price...';

  // Empty States
  static const String noPopularListingsText = 'No listings found';
  static const String noSearchResultsText = 'No properties found';
  static const String popularListingsTitle = 'Popular Listings';

  // Icons
  static const double iconSize = 20;
  static const double largeIconSize = 48;
  static const double filterIconSize = 22;

  // Filter Modal
  static const double filterModalBorderRadius = 24;
}
