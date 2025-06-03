import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'loginandregister.dart';

// Dummy colors for example; replace with your actual AppColors.text or import your colors
class AppColors {
  static const text = Colors.black87;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "images": [
        "images/onbording/audience.jpg",
        "images/onbording/concert.jpg",
        "images/onbording/fireworks.jpg",
        "images/onbording/concert1.jpg",
        "images/onbording/artist.jpg",
        "images/onbording/confetti.jpg",
      ],
      "title": "Find your favourite events here",
      "subtitle": "Discover events that match your interests — from concerts to workshops.",
      "button": "Next"
    },
    {
      "images": [
        "images/onbording/onbordiing2/couple.jpg",
        "images/onbording/onbordiing2/audience1.jpg",
        "images/onbording/onbordiing2/dualipa.jpg",
        "images/onbording/onbordiing2/fireworks1.jpg",
        "images/onbording/onbordiing2/hands.jpg",
        "images/onbording/onbordiing2/lake.jpg",
      ],
      "title": "Find your nearby event here",
      "subtitle": "Get personalized recommendations for events happening around you.",
      "button": "Next"
    },
    {
      "images": [
        "images/onbording/onbording3/guitar.jpg",
        "images/onbording/onbording3/music.jpg",
        "images/onbording/onbording3/people3.jpg",
        "images/onbording/onbording3/people4.jpg",
        "images/onbording/onbording3/pyrotechnics.jpg",
        "images/onbording/onbording3/table.jpg",
      ],
      "title": "Update your upcoming event here",
      "subtitle": "Create, manage, or update your own events easily in one place.",
      "button": "Get Started"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final orientation = MediaQuery.of(context).orientation;

    Widget pageViewContent(int index) {
      final item = onboardingData[index];
      final hasGridImages = item.containsKey('images');

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: orientation == Orientation.portrait ? 6 : 4,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                ),
                child: hasGridImages
                    ? StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 3,
                      mainAxisCellCount: 6 / 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['images'][0],
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 6 / 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['images'][1],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 12 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['images'][2],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 3,
                      mainAxisCellCount: 12 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['images'][3],
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 3,
                      mainAxisCellCount: 6 / 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['images'][4],
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 1,
                      mainAxisCellCount: 6 / 7,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item['images'][5],
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    item['image'],
                    width: orientation == Orientation.portrait ? width * 0.9 : 400,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.03),
          Flexible(
            flex: orientation == Orientation.portrait ? 2 : 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.014),
                Text(
                  item['subtitle'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: width * 0.04,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            orientation == Orientation.portrait
                ? buildPortraitLayout(width, height, pageViewContent)
                : SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: buildLandscapeLayout(width, height, pageViewContent),
              ),
            ),

            // Skip button at top right
            Positioned(
              top: 0,
              right: 0,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginAndRegister()),
                  );
                },
                child: Container(
                  height: 40,
                  width: 65,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.pink.shade100),
                  child: Center(
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPortraitLayout(
      double width, double height, Widget Function(int) pageViewContent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.01, vertical: height * 0.02),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) => pageViewContent(index),
            ),
          ),
          SizedBox(height: height * 0.02),
          SmoothPageIndicator(
            controller: _controller,
            count: onboardingData.length,
            effect: WormEffect(
              activeDotColor: Colors.pink,
              dotHeight: 12,
              dotWidth: 12,
              spacing: 8,
            ),
          ),
          SizedBox(height: height * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: ElevatedButton(
              onPressed: () {
                if (_currentIndex < onboardingData.length - 1) {
                  _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginAndRegister()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: Size(double.infinity, height * 0.065),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                onboardingData[_currentIndex]['button'],
                style: TextStyle(fontSize: width * 0.045, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: height * 0.03),
        ],
      ),
    );
  }

  Widget buildLandscapeLayout(
      double width,
      double height,
      Widget Function(int) pageViewContent,
      ) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 3.55,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) => pageViewContent(index),
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SmoothPageIndicator(
                  controller: _controller,
                  count: onboardingData.length,
                  effect: WormEffect(
                    activeDotColor: Colors.pink,
                    dotHeight: 12,
                    dotWidth: 12,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < onboardingData.length - 1) {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginAndRegister()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: Size(double.infinity, height * 0.065),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      onboardingData[_currentIndex]['button'],
                      style: TextStyle(fontSize: width * 0.045, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
