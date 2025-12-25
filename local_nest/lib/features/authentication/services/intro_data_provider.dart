import '../models/models.dart';

/// Abstract interface for providing intro options data
/// Follows Dependency Inversion Principle
abstract class IntroDataProvider {
  List<IntroOption> getIntroOptions();
}
