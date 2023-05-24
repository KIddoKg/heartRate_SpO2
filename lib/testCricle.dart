import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DemoCircleWave extends StatelessWidget {
  final int count;
  final bool isProcessing;

  DemoCircleWave({required this.count, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Occupy all available width
      height: double.infinity, // Occupy all available height
      decoration: BoxDecoration(
        color: Colors.blue, // Set the background color as desired
        borderRadius: BorderRadius.circular(
            8.0), // Apply border radius if needed
      ),
      child: Center(
        child: Text(
          'Demo Circle Wave',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}