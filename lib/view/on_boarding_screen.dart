import 'package:store_app/controllers/auth_controller.dart';
import 'package:store_app/utils/app_textstyles.dart';
import 'package:store_app/view/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _item = [
    OnboardingItem(
      image: 'assets/images/intro.png',
      title: 'discover latest fashion',
      description: 'explore the newest fashion trends',
    ),
    OnboardingItem(
      image: 'assets/images/intro1.png',
      title: 'quality products',
      description: 'shop premium brands at best prices',
    ),
    OnboardingItem(
      image: 'assets/images/intro2.png',
      title: 'easy shopping',
      description:
          'simple and secure shopping experience at your fingertips',
    ),
  ];

  void _handleGetStarted() {
    final authController = Get.find<AuthController>();
    authController.setFirstTimeDone();
    Get.off(() => SigninScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _item.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _item[index].image,
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _item[index].title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.withColor(
                      AppTextStyles.h1,
                      Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _item[index].description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.withColor(
                        AppTextStyles.bodyLarge,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _item.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).primaryColor
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _handleGetStarted,
                  child: Text(
                    "Skip",
                    style: AppTextStyles.withColor(
                      AppTextStyles.buttonMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _item.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _handleGetStarted();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _item.length - 1
                        ? 'Get Started'
                        : "Next",
                    style: AppTextStyles.withColor(
                        AppTextStyles.buttonMedium, Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}
