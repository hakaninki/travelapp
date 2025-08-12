import 'package:flutter/material.dart';

class ExploreBar extends StatelessWidget {
  const ExploreBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 30,
        right: 30,
        //top: MediaQuery.of(context).size.height / 3.0,
      ),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.only(
                left: 20,
                top: 10,
                bottom: 10,
              ),
              hintText: "Explore places",
              hintStyle: TextStyle(
                color: const Color.fromARGB(143, 160, 84, 84),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              suffixIcon: Icon(
                Icons.travel_explore_outlined,
                color: const Color.fromARGB(143, 160, 84, 84),
                size: 30,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
