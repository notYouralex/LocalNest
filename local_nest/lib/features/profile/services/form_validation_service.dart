/// Form Validation Service - Encapsulates all validation logic
class FormValidationService {
  static const int minNameLength = 3;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const double minRent = 1000;
  static const double maxRent = 1000000;

  /// Validate property name
  static String? validatePropertyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Property name is required';
    }
    if (value.length < minNameLength) {
      return 'Property name must be at least $minNameLength characters';
    }
    if (value.length > maxNameLength) {
      return 'Property name cannot exceed $maxNameLength characters';
    }
    return null;
  }

  /// Validate address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    if (value.length < 5) {
      return 'Please provide a complete address';
    }
    return null;
  }

  /// Validate city
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    return null;
  }

  /// Validate description
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length < 20) {
      return 'Description should be at least 20 characters';
    }
    if (value.length > maxDescriptionLength) {
      return 'Description cannot exceed $maxDescriptionLength characters';
    }
    return null;
  }

  /// Validate monthly rent
  static String? validateRent(String? value) {
    if (value == null || value.isEmpty) {
      return 'Monthly rent is required';
    }
    final rent = double.tryParse(value);
    if (rent == null) {
      return 'Please enter a valid amount';
    }
    if (rent < minRent) {
      return 'Minimum rent is ₱${minRent.toStringAsFixed(0)}';
    }
    if (rent > maxRent) {
      return 'Maximum rent is ₱${maxRent.toStringAsFixed(0)}';
    }
    return null;
  }

  /// Validate slots
  static String? validateSlots(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final slots = int.tryParse(value);
    if (slots == null || slots < 0) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validate available slots vs total slots
  static String? validateSlotRelationship(int available, int total) {
    if (total <= 0) {
      return 'Total slots must be greater than 0';
    }
    if (available > total) {
      return 'Available slots cannot exceed total slots';
    }
    if (available < 0) {
      return 'Available slots cannot be negative';
    }
    return null;
  }

  /// Validate photos
  static String? validatePhotos(List<String> photos) {
    if (photos.isEmpty) {
      return 'At least one photo is required';
    }
    if (photos.length > 10) {
      return 'Maximum 10 photos allowed';
    }
    return null;
  }

  /// Validate entire form data
  static String? validateFormData({
    required String propertyName,
    required String address,
    required String city,
    required String description,
    required String rent,
    required int availableSlots,
    required int totalSlots,
    required List<String> photos,
  }) {
    // Check each field
    var error = validatePropertyName(propertyName);
    if (error != null) return error;

    error = validateAddress(address);
    if (error != null) return error;

    error = validateCity(city);
    if (error != null) return error;

    error = validateDescription(description);
    if (error != null) return error;

    error = validateRent(rent);
    if (error != null) return error;

    error = validateSlots(availableSlots.toString(), fieldName: 'Available slots');
    if (error != null) return error;

    error = validateSlots(totalSlots.toString(), fieldName: 'Total slots');
    if (error != null) return error;

    error = validateSlotRelationship(availableSlots, totalSlots);
    if (error != null) return error;

    error = validatePhotos(photos);
    if (error != null) return error;

    return null; // All validations passed
  }
}
