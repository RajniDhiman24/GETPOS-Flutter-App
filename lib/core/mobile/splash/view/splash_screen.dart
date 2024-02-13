import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_posx/core/mobile/theme/theme_setting_screen.dart';
import '../../../../constants/asset_paths.dart';
import '../../../../main.dart';
import '../../home/ui/product_list_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint("inside splash screen");
    debugPrint("is User logged in :$isUserLoggedIn");
    Timer(
        const Duration(seconds: 3),
        (() => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => isUserLoggedIn
                    ? const ProductListHome()
                    : const ThemeChange()))));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 254, 253, 253),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Stack(
            children: [
              Center(
                  child: Image.asset(
                App_ICON,
                width: 200,
                height: 200,
              )),
              const SizedBox(height: 15),
              // Padding(
              //     padding: const EdgeInsets.only(bottom: 30),
              //     child: Align(
              //         alignment: Alignment.bottomCenter,
              //         child: Text(
              //           POWERED_BY_TXT,
              //           style: getTextStyle(color: BLACK_COLOR, fontSize: 16.0),
              //         )))
            ],
          ),
        ),
      ),
    );
  }
}
