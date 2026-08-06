import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/widgets/custom_button.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {

  int _currentIndex = 0;

  final PageController _pageController = PageController();
  Timer? _timer;


  final List<String> _bgImages = [
    "assets/images/sate.jpg",
    "assets/images/dimsum.jpg",
    "assets/images/nasi_goreng.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentIndex < _bgImages.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
           child: PageView.builder(
              controller: _pageController,
              itemCount: _bgImages.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _bgImages[index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Taste Excelent",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Seamless Ordering for the Modern Epicurean.",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Row(
                    children: List.generate(
                      _bgImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300), 
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentIndex == index ? 35 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? Colors.white
                              : const Color.fromARGB(255, 156, 155, 155),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  )
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 40, bottom: 50),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomButton(
                        text: "Get Started",
                        onPressed: () {
                         Navigator.pushNamed(context, "/regist");
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      CustomButton(
                        text: "Login",
                        onPressed: () {
                         Navigator.pushNamed(context, "/login");
                        },
                        isPrimary: false,
                      ),
                    ],
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
