import 'package:flutter/material.dart';
import 'services/firestoreService.dart';
import 'Auth/direct.dart';
import 'Auth/furtherInfoToSignUpPage.dart';
import 'services/authService.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'Auth/loginPage.dart';
import 'Auth/signUpPage.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bodyContainer(),
        ],
      ),
    );
  }

  Container _bodyContainer() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Image.asset('assets/appIcon.png', height: 200, width: 200),
          const SizedBox(height: 20),
          const Text(
            "Welcome",
            style: TextStyle(
              color: Colors.green,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Tirbuschon",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 50,
            ),
          ),
          const MottoText(),
          const SizedBox(height: 15),
          Column(
            children: [
              LoginContainer(context: context),
              const SizedBox(height: 30),
              SignUpContainer(context: context),
              const SizedBox(height: 30),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  child: GoogleSignUp(context: context)),
            ],
          ),
        ],
      ),
    );
  }
}

class GoogleSignUp extends StatelessWidget {
  const GoogleSignUp({Key? key, required this.context}) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SignInButton(Buttons.Google, text: "Continue with Google",
            onPressed: () {
      alertUser();
    }));
  }

  void alertUser() {
    Widget yesButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _signInWithGoogle();
        },
        child: const Text("Yes"));

    Widget noButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop();

          Widget okButton = TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                var navigateDialog = AlertDialog(
                  title: const Text("Please wait..."),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(height: 10),
                      Text("Navigating to login page...")
                    ],
                  ),
                );

                showDialog(
                    context: context,
                    builder: (BuildContext context) => navigateDialog);

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.of(context).pop();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                });
              },
              child: const Text("OK"));

          var infoDialog = AlertDialog(
            title: const Text("Info"),
            content:
                const Text("Venue owners must login with the given email."),
            actions: [okButton],
          );

          showDialog(
              context: context, builder: (BuildContext context) => infoDialog);
        },
        child: const Text("No"));

    var alertDialog = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Do you confirm that you're not a venue owner?"),
      actions: [noButton, yesButton],
    );

    showDialog(
        context: context, builder: (BuildContext context) => alertDialog);
  }

  void _signInWithGoogle() async {
    final AuthService _authService = AuthService();
    final FirestoreService _firestoreService = FirestoreService();

    final googleUser = await _authService.signInWithGoogle();
    final String userID, email, avatarURL;
    userID = googleUser!.uid;
    email = googleUser.email!;
    avatarURL = googleUser.photoURL!;

    var result = await _firestoreService.userExists(userID);
    if (result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Direct()),
      );
    } else {
      _authService.createGoogleUser(email, userID, avatarURL);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FurtherInfoToSignUpPage(id: userID)),
      ).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      });
    }
  }
}

class SignUpContainer extends StatelessWidget {
  const SignUpContainer({Key? key, required this.context}) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width - 50,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpPage()),
          );
        },
        child: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(45),
      ),
    );
  }
}

class LoginContainer extends StatelessWidget {
  const LoginContainer({Key? key, required this.context}) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width - 50,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(45),
      ),
    );
  }
}

class MottoText extends StatelessWidget {
  const MottoText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(15.0),
      child: Text(
        "Making reservations with Tirbuschon is easy peasy!",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
