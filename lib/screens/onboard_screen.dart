import 'package:flutter/material.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color.fromARGB(255, 0, 25, 42)),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Expanded(
                flex: 2,
                child: Image.asset(
                  "assets/images/onboard.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Column(
                    children: [
                      Text(
                        "Discover. React. Connect",
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Track your favorites, share quick reactions, and explore films with a passionate community.",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 50),

                      GestureDetector(
                        //TODO : Implement navigation OnClick the button
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Theme.of(context).primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              // ADD THIS
                              BoxShadow(
                                color: Color(0x252596BE), // Cyan 25% opacity
                                blurRadius: 15,
                                spreadRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Text(
                            "Get Started",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
