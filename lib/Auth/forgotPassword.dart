import 'package:flutter/material.dart';
import '../services/authService.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late String email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: _emailTextField(),
          ),
          const SizedBox(
            height: 20,
          ),
          ResetPasswordButton(email: email, context: context),
        ],
      ),
    );
  }

  TextField _emailTextField() {
    return TextField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.mail),
        labelText: "Email",
        hintText: "Please enter your email",
      ),
      onChanged: (value) {
        setState(() {
          email = value;
        });
      },
    );
  }
}

class ResetPasswordButton extends StatelessWidget {
  const ResetPasswordButton({
    Key? key,
    required this.email,
    required this.context,
  }) : super(key: key);

  final String email;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    var isEnabled = email.isNotEmpty;
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width - 10,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isEnabled ? Colors.blueAccent : Colors.grey,
          border: Border.all(
            width: 1,
          )),
      child: TextButton(
        onPressed: isEnabled
            ? () {
                _resetPassword(email);
              }
            : null,
        child: const Text(
          "Request Password Reset",
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
          ),
        ),
      ),
    );
  }

  void _resetPassword(String email) {
    final AuthService _authService = AuthService();

    // no limitation on reset password form
    _authService.resetPassword(email).catchError((error) {
      String errorDetail;
      if (error.toString().contains('invalid-email')) {
        errorDetail = "Email is badly formatted";
      } else if (error.toString().contains('user-not-found')) {
        errorDetail = "The user has not been found.";
      } else {
        errorDetail = "There is an error that we can not define.$error";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorDetail.toString()),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("A link has been sent you to reset your password."),
    ));
  }
}
