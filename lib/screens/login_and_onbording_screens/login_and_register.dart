import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/onording_login_screens_providers/google_signin_provider.dart';
import '../home_screens/home_screen.dart';

class LoginAndRegister extends StatelessWidget {
  const LoginAndRegister({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final googleProvider = Provider.of<GoogleSignInProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipPath(
                    clipper: BottomCurveClipper(),
                    child: Container(
                      height: size.height * 0.6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('images/register_image.png'),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.green[100],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                      vertical: size.height * 0.03,
                    ),
                    color: Colors.white,
                    child: Column(
                      children: [
                        Text(
                          "Join to our festival community",
                          style: TextStyle(
                            fontSize: 28 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Start your festival today in great company with good peoples. A community is a social unit with commonality.",
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: googleProvider.isSigningIn
                                ? null
                                : () async {
                                    final user = await googleProvider
                                        .signInWithGoogle(context);
                                    print(user?.displayName);
                                    if (user != null) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const HomeScreen()),
                                      );
                                    }
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('images/google.png', height: 30),
                                const SizedBox(width: 10),
                                Text(
                                  'Login with Google',
                                  style: TextStyle(
                                    fontSize: 18 * textScale,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (googleProvider.isSigningIn)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 90);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 90,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
