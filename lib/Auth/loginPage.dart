import 'package:flutter/material.dart';
import 'direct.dart';
import '../services/authService.dart';
import 'forgotPassword.dart';
import 'signUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String email = "", password = "";

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        backgroundColor: Colors.grey[100],
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      "Tirbuschon",
                      style: TextStyle(
                        fontSize: 42,
                        color: Colors.blue[400],
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        ForgotPasswordButton(context: context),
                        const SizedBox(height: 10),
                        LoginButton(
                            email: email,
                            password: password,
                            context: context,
                            formKey: _formKey),
                      ],
                    ),
                    NewUserReminderButton(context: context),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextField _passwordTextField() {
    return TextField(
      obscureText: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: "Password",
        hintText: "Please enter your password",
      ),
      onChanged: (value) {
        setState(() {
          password = value.toString();
        });
      },
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
          email = value.toString();
        });
      },
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({
    Key? key,
    required this.email,
    required this.password,
    required this.context,
    required this.formKey,
  }) : super(key: key);

  final String email;
  final String password;
  final BuildContext context;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    var isEmailNull = email.isEmpty;
    var isPasswordNull = password.isEmpty;
    var result = isEmailNull || isPasswordNull;
    var isDisabled = result;

    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width - 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(width: 1),
        color: isDisabled ? Colors.grey : Colors.blue,
      ),
      child: TextButton(
        onPressed: isDisabled
            ? null
            : () {
                _loginWithEmailPassword();
              },
        child: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void _loginWithEmailPassword() async {
    final AuthService _authService = AuthService();

    var _formState = formKey.currentState;
    if (_formState!.validate()) {
      _formState.save();

      await _authService.signInWithEmail(email, password).then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Direct()),
            (route) => false);
      }).catchError((error) {
        String errorDetail;
        if (error.toString().contains('invalid-email')) {
          errorDetail = "Email is invalid";
        } else if (error.toString().contains('user-not-found')) {
          errorDetail = "The user is not found.";
        } else if (error.toString().contains('wrong-password')) {
          errorDetail = "The password is wrong.";
        } else {
          errorDetail = "Fields can not be empty.";
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorDetail.toString()),
        ));
      });
    }
  }
}

class NewUserReminderButton extends StatelessWidget {
  const NewUserReminderButton({
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
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      child: const Text(
        "New User? Create Account.",
        style: TextStyle(color: Colors.black87),
      ),
    );
  }
}

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({
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
          MaterialPageRoute(
            builder: (context) => const ForgotPassword(),
          ),
        );
      },
      child: const Text(
        "Forgot Password?",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 15,
        ),
      ),
    );
  }
}
