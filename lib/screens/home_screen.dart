import 'package:flutter/material.dart';
import '../widgets/custom_button_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Rounded App Icon or Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16), // You can adjust this value
                    child: Image.asset(
                      'assets/icon/icon.jpg',
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),

                const SizedBox(height: 32),

                // White text above the button
                const Text(
                  'Choose your option',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 7, 7, 7), // Change text color to black
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button with black background and smaller size
                CustomButton(
                  text: 'Login',
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  buttonColor: Colors.black, // Set button color to black
                  height: 40, // Adjust the height for smaller button
                  width: double.infinity, // Makes the button stretch across the screen
                ),

                const SizedBox(height: 12),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 12),

                // Sign up Button with black background and smaller size
                CustomButton(
                  text: 'Sign up',
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  buttonColor: Colors.black, // Set button color to black
                  height: 40, // Adjust the height for smaller button
                  width: double.infinity, // Makes the button stretch across the screen
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
