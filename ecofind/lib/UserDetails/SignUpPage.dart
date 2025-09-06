import 'package:flutter/material.dart';
import 'package:ecofind/Components/Colors.dart';
import 'package:ecofind/Components/TextField.dart';
import 'package:ecofind/Components/ElevationButton.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController Username = TextEditingController();
  final TextEditingController UserEmail = TextEditingController();
  final TextEditingController UserPassword = TextEditingController();
  final TextEditingController ConfirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 15),
              CircleAvatar(
                radius: 75,
                backgroundImage: AssetImage("assets/Logo.png"),
              ),
              SizedBox(height: 24),
              Text(
                "Create an Account !",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15),
              textfield(
                hintText: "Enter Your Name",
                icon: Icons.person,
                labelText: "UserName",
                controller: Username,
              ),
              SizedBox(height: 20),
              textfield(
                hintText: "Enter your Email",
                icon: Icons.email_outlined,
                labelText: "Email",
                controller: UserEmail,
              ),
              SizedBox(height: 20),
              textfield(
                hintText: "Password",
                icon: Icons.password,
                labelText: "Password",
                controller: UserPassword,
              ),
              SizedBox(height: 20),
              textfield(
                hintText: "Confirm Password",
                icon: Icons.password,
                labelText: "Confirm Password",
                controller: ConfirmPassword,
              ),
              SizedBox(height: 30),
              Elevationbutton(
                name: "Submit",
                bgColor: 0xFFE8721C,
                //purple
                textColor: 0xFFFFFFFF,
                fontsize: 18,
                radius: 15,
                padding: 15,
                icon: Icons.groups,
                routePage: "/",
                iconcolor: 0xFFFFFFFF,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
