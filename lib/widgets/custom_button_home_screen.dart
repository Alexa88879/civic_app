import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor; // Added button color
  final double height; // Added height
  final double width;  // Added width

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.buttonColor = Colors.blue, // Default to blue if no color provided
    this.height = 60.0, // Default height
    this.width = double.infinity, // Default to full width
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor, // Set button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18),

        ),
      ),
    );
  }
}
