import 'package:flutter/material.dart';
import '../services/authService.dart';
import 'furtherInfoToSignUpPage.dart';
import 'loginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late String email = "",
      password = "",
      confirmedPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tirbuschonText(),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _emailTextField(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _passwordTextField(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _confirmPasswordTextField(),
                            ),
                            const SizedBox(height: 10),
                            SignUpButton(
                                context: context,
                                email: email,
                                password: password,
                                confirmedPassword: confirmedPassword,
                                formKey: _formKey),
                          ],
                        ),
                      ],
                    ),
                    AlreadySignedUpReminderButton(context: context),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  TextFormField _passwordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: "Password",
        hintText: "Please enter your password",
      ),
      validator: (value) {
        String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$';
        String? errorDetail;

        if (value!.isEmpty) {
          errorDetail = "Password field can not be empty!";
        } else if (!value.contains(RegExp(pattern))) {
          errorDetail =
          "1 uppercase, 1 lowercase and 1 numeric with at least 6 in total.";
        }

        return errorDetail ?? null;
      },
      onChanged: (value) {
        setState(() {
          password = value.toString();
        });
      },
    );
  }

  TextFormField _confirmPasswordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: "Confirm Password",
        hintText: "Please confirm your password",
      ),
      validator: (value) {
        String? errorDetail;

        if (confirmedPassword != password) {
          errorDetail = "Passwords should be matched!";
        }

        return errorDetail ?? null;
      },
      onChanged: (value) {
        setState(() {
          confirmedPassword = value.toString();
        });
      },
    );
  }

  TextFormField _emailTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.mail),
        labelText: "Email",
        hintText: "Please enter your email",
      ),
      validator: (value) {
        String? errorDetail;

        if (value!.isEmpty) {
          errorDetail = "Email field can not be empty!";
        } else if (!value.contains("@")) {
          errorDetail = "Value should be an email format.";
        } else if (value.contains("@tirbuschon.com")) {
          errorDetail = "You cannot signup with @tirbuschon.com domain.";
        } else if (value.contains("@tirbuschon.admin.com")) {
          errorDetail = "You cannot signup with @tirbuschon.admin.com domain.";
        }

        return errorDetail ?? null;
      },
      onChanged: (value) {
        setState(() {
          email = value.toString();
        });
      },
    );
  }

  Text _tirbuschonText() {
    return Text(
      "Tirbuschon",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: Colors.blue[400],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class AlreadySignedUpReminderButton extends StatelessWidget {
  const AlreadySignedUpReminderButton({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      },
      child: const Text("Signed Up Before? Login Instead."),
    );
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({Key? key,
    required this.context,
    required this.formKey,
    required this.email,
    required this.password,
    required this.confirmedPassword})
      : super(key: key);

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final String email, password, confirmedPassword;

  @override
  Widget build(BuildContext context) {
    var isEmailNull = email.isEmpty;
    var isPasswordNull = password.isEmpty;
    var isConfirmedPasswordNull = confirmedPassword.isEmpty;
    var result = isEmailNull || isPasswordNull || isConfirmedPasswordNull;
    var isDisabled = result;

    return Container(
      height: 50,
      width: MediaQuery
          .of(context)
          .size
          .width - 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(width: 1),
        color: isDisabled ? Colors.grey : Colors.blue,
      ),
      child: TextButton(
        onPressed: isDisabled
            ? null
            : () {
          _createUser();
        },
        child: const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void _createUser() async {
    final AuthService _authService = AuthService();
    try {
      var _formState = formKey.currentState!;
      if (_formState.validate()) {
        _formState.save();

        var uid = await _authService.createUser(email, password);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FurtherInfoToSignUpPage(id: uid)));
      }
    } on Exception catch (e) {
      String errorDetail;
      if (e.toString().contains('user-disabled')) {
        errorDetail = "This account is disabled.";
      } else if (e.toString().contains('already-in-use')) {
        errorDetail = "This email is already in use.";
      }
      else {
        errorDetail = "$e";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorDetail.toString()),
      ));
    }
  }
}
