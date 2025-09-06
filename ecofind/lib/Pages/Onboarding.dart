import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:ecofind/Pages/LoginPage.dart';




class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "",
      "description": "",
      "image": "assets/1.png",
    },
    {
      "title": "",
      "description": "",
      "image": "assets/page.1.png",
    },
    {
      "title": "",
      "description": "",
      "image": "assets/page.2.png",
    },    {
      "title": "",
      "description": "",
      "image": "assets/page.3.png",
    },
  ];

  void _nextPage() {
    if(_currentPage < onboardingData.length -1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut
      );
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) => OnboardingPage(
                    title: onboardingData[index]["title"]!,
                    description: onboardingData[index]["description"]!,
                    image: onboardingData[index]["image"]!,
                    indicator:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                            (index) => buildDot(index),
                      ),
                    ),
                    button:   ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: Text(
                        _currentPage == onboardingData.length - 1 ? "Finish" : "Got It!",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: _currentPage == index ? 12 : 8,
      height: _currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey,
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title, description, image;
  final Widget indicator,button;


  const OnboardingPage({super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.indicator,
    required this.button
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(image),
                fit: BoxFit.cover)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15,sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white60, Colors.white10]),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(width: 2,color: Colors.white30),
                        ),
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                description,
                                style: const TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            indicator,
                            const SizedBox(height: 10),
                            button

                          ],
                        ),
                      ),
                    ),
                  ),
                )
            ),
          ],
        )
    );

  }
}