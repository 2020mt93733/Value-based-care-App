import 'package:flutter/material.dart';
import 'package:valuebasedcare/screens/login/login_screen.dart';
import 'package:valuebasedcare/screens/Signup/components/background.dart';
import 'package:valuebasedcare/Screens/Signup/components/or_divider.dart';
import 'package:valuebasedcare/Screens/Signup/components/social_icon.dart';
import 'package:valuebasedcare/components/already_have_an_account_acheck.dart';
import 'package:valuebasedcare/components/rounded_button.dart';
import 'package:valuebasedcare/components/rounded_input_field.dart';
import 'package:valuebasedcare/components/rounded_password_field.dart';
import 'package:flutter_svg/svg.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
              hintText: "Your Email",
              onChanged: (value) {},
            ),
            RoundedPasswordField(
              onChanged: (value) {},
            ),
            RoundedButton(
              text: "SIGNUP",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/facebook.png",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/twitter.png",
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/google.png",
                  press: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}