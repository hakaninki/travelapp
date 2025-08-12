import 'package:flutter/material.dart';
//import 'package:travel_app/features/home/home_page.dart';
import 'package:travel_app/features/main/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Center(
          child: Image.asset("images/splash5.png", fit: BoxFit.cover, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, alignment: Alignment.center
        ),
      ),
    ),);
  }
  @override
void initState() {
  super.initState();
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  });
}

}
