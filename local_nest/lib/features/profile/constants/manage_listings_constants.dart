/// Constants for Manage Listings feature
class ManageListingsConstants {
  ManageListingsConstants._();

  // Spacing & Layout
  static const double contentPadding = 16.0;
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 12.0;
  static const double cardSpacing = 16.0;

  // Border & Shape
  static const double cardBorderRadius = 14.0;
  static const double buttonBorderRadius = 8.0;
  static const double headerBorderRadius = 16.0;
  static const double badgeBorderRadius = 8.0;
  static const double borderWidth = 1.18;

  // Icons
  static const double smallIconSize = 16.0;
  static const double iconSize = 16.0;
  static const double largeIconSize = 20.0;
  static const double headerIconSize = 20.0;

  // Buttons
  static const double buttonHeight = 32.0;
  static const double smallButtonWidth = 38.0;
  static const double minActionButtonWidth = 60.0;

  // Header
  static const double headerBackButtonSize = 36.0;
  static const double headerBackButtonIconSize = 20.0;

  // Stats
  static const double statCardHeight = 80.0;
  static const double statFontSize = 24.0;
  static const double statLabelFontSize = 12.0;

  // Text
  static const String pageTitle = 'Manage Listings';
  static const String addListingButton = 'Add Listing';
  static const String activeLabel = 'Active';
  static const String inactiveLabel = 'Inactive';
  static const String deactivateButton = 'Deactivate';
  static const String activateButton = 'Activate';
  static const String editButton = 'Edit';
  static const String deleteButton = 'Delete';
  static const String priceLabel = 'Price';
  static const String roomTypeLabel = 'Room Type';
  static const String availableLabel = 'Available';
  static const String viewsLabel = 'Views';
  static const String viewsIcon = 'views';
  static const String inquiriesLabel = 'Inquiries';
  static const String inquiriesIcon = 'inquiries';

  // Stats labels
  static const String activeCountStat = 'Active';
  static const String viewsCountStat = 'Views';
  static const String inquiriesCountStat = 'Inquiries';

  // Dialog messages
  static const String deleteDialogTitle = 'Delete Listing';
  static const String deleteDialogContent = 'Are you sure you want to delete this listing?';
  static const String cancelButtonLabel = 'Cancel';
  static const String deleteButtonLabel = 'Delete';
  static const String successDeleteMessage = 'Listing deleted';
  static const String addListingComingSoon = 'Add Listing - Coming Soon';
  static const String editListingComingSoon = 'Edit Listing - Coming Soon';

  // Colors - Using string keys to reference AppColors
  // These are mapped in the UI layer
  static const String activeBadgeColor = 'success'; // #10b981
  static const String inactiveBadgeColor = 'textSecondary';
  static const String priceTextColor = 'primary'; // Cyan #06b6d4
  static const String headerGradientStart = '#238B45';
  static const String headerGradientEnd = '#1e7e34';
  static const String addButtonGradientStart = '#06b6d4';
  static const String addButtonGradientEnd = '#0891b2';

  // Opacity values
  static const double headerBackgroundOpacity = 0.1;
  static const double statCardOpacity = 0.1;

  // Default values for mock data
  static const int defaultActiveListings = 2;
  static const int defaultTotalViews = 879;
  static const int defaultTotalInquiries = 43;
}
