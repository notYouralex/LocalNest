import 'package:flutter/material.dart';

// ============================================================================
// MODELS & ENTITIES
// ============================================================================

class IntroOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final List<FeatureItem> features;
  final String buttonText;
  final Color buttonColor;
  final Color borderColor;
  final bool isOutline;

  const IntroOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.features,
    required this.buttonText,
    required this.buttonColor,
    required this.borderColor,
    this.isOutline = false,
  });
}

class FeatureItem {
  final IconData icon;
  final String label;
  final Color color;

  const FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

// ============================================================================
// ABSTRACT INTERFACES (Dependency Inversion Principle)
// ============================================================================

abstract class IntroDataProvider {
  List<IntroOption> getIntroOptions();
}

abstract class IntroNavigationService {
  void onRenterSelected();
  void onLandlordSelected();
}

// ============================================================================
// CONCRETE IMPLEMENTATIONS
// ============================================================================

class DefaultIntroDataProvider implements IntroDataProvider {
  @override
  List<IntroOption> getIntroOptions() {
    return [
      IntroOption(
        id: 'renter',
        title: 'Looking for a Place',
        subtitle: 'Find verified boarding houses near you',
        icon: Icons.search,
        iconColor: const Color(0xFF238B45),
        iconBgColor: const Color(0xFF238B45).withOpacity(0.1),
        features: const [
          FeatureItem(
            icon: Icons.location_on,
            label: 'Map Search',
            color: Color(0xFF238B45),
          ),
          FeatureItem(
            icon: Icons.shield,
            label: 'Verified',
            color: Color(0xFF41AB5D),
          ),
          FeatureItem(
            icon: Icons.favorite,
            label: 'Save Favorites',
            color: Color(0xFFFB7185),
          ),
        ],
        buttonText: 'Continue as Renter',
        buttonColor: const Color(0xFF238B45),
        borderColor: const Color(0xFF238B45),
      ),
      IntroOption(
        id: 'landlord',
        title: "I'm a Landlord",
        subtitle: 'List and manage your properties',
        icon: Icons.home,
        iconColor: const Color(0xFF0F172A),
        iconBgColor: const Color(0xFF0F172A).withOpacity(0.1),
        features: const [
          FeatureItem(
            icon: Icons.auto_awesome,
            label: 'Easy Listing',
            color: Color(0xFF0F172A),
          ),
          FeatureItem(
            icon: Icons.shield,
            label: 'Get Verified',
            color: Color(0xFF41AB5D),
          ),
        ],
        buttonText: 'Continue as Landlord',
        buttonColor: Colors.transparent,
        borderColor: const Color(0xFF0F172A),
        isOutline: true,
      ),
    ];
  }
}

// ============================================================================
// PRESENTATION LAYER - SCREENS & WIDGETS
// ============================================================================

class IntroScreen extends StatelessWidget {
  final IntroNavigationService navigationService;
  final IntroDataProvider dataProvider;

  const IntroScreen({
    Key? key,
    required this.navigationService,
    required this.dataProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF41AB5D),
              Color(0xFF238B45),
              Color(0xFF006D2C),
            ],
          ),
        ),
        child: Column(
          children: [
            _IntroHeader(),
            Expanded(
              child: _IntroContent(
                dataProvider: dataProvider,
                navigationService: navigationService,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroHeader extends StatelessWidget {
  const _IntroHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 24, left: 24, right: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.home,
                size: 32,
                color: Color(0xFF238B45),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'LocalNest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your perfect home',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroContent extends StatelessWidget {
  final IntroDataProvider dataProvider;
  final IntroNavigationService navigationService;

  const _IntroContent({
    Key? key,
    required this.dataProvider,
    required this.navigationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final options = dataProvider.getIntroOptions();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Welcome! 👋',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'How can we help you today?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _OptionCardWidget(
                  option: option,
                  onTap: () => _handleOptionSelection(option.id),
                ),
              );
            }),
            const Text(
              'You can change your account type anytime',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOptionSelection(String optionId) {
    if (optionId == 'renter') {
      navigationService.onRenterSelected();
    } else if (optionId == 'landlord') {
      navigationService.onLandlordSelected();
    }
  }
}

class _OptionCardWidget extends StatefulWidget {
  final IntroOption option;
  final VoidCallback onTap;

  const _OptionCardWidget({
    Key? key,
    required this.option,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_OptionCardWidget> createState() => _OptionCardWidgetState();
}

class _OptionCardWidgetState extends State<_OptionCardWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.option.borderColor.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OptionHeader(option: widget.option),
              const SizedBox(height: 16),
              _FeaturesList(features: widget.option.features),
              const SizedBox(height: 16),
              _OptionButton(option: widget.option, onTap: widget.onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionHeader extends StatelessWidget {
  final IntroOption option;

  const _OptionHeader({Key? key, required this.option}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: option.iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            option.icon,
            size: 24,
            color: option.iconColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                option.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturesList extends StatelessWidget {
  final List<FeatureItem> features;

  const _FeaturesList({Key? key, required this.features}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features
          .map((feature) => _FeatureChip(feature: feature))
          .toList(),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final FeatureItem feature;

  const _FeatureChip({Key? key, required this.feature}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: feature.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(feature.icon, size: 12, color: feature.color),
          const SizedBox(width: 6),
          Text(
            feature.label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IntroOption option;
  final VoidCallback onTap;

  const _OptionButton({
    Key? key,
    required this.option,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              option.isOutline ? Colors.transparent : option.buttonColor,
          foregroundColor:
              option.isOutline ? const Color(0xFF0F172A) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: option.isOutline
                ? BorderSide(color: option.borderColor.withOpacity(0.2))
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              option.buttonText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      ),
    );
  }
}
