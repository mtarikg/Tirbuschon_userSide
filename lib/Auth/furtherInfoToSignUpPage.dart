import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'direct.dart';
import '../services/authService.dart';

class FurtherInfoToSignUpPage extends StatefulWidget {
  final String? id;

  const FurtherInfoToSignUpPage({required this.id, Key? key}) : super(key: key);

  @override
  _FurtherInfoToSignUpPageState createState() =>
      _FurtherInfoToSignUpPageState();
}

class _FurtherInfoToSignUpPageState extends State<FurtherInfoToSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late String username = "", fullName = "", phoneNumber = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tirbuschonText(),
                    const SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: _fullNameTextField(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: _usernameTextField(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: _phoneNumberTextField(),
                        ),
                        const SizedBox(height: 10),
                        CompleteButton(
                          context: context,
                          formKey: _formKey,
                          id: widget.id!,
                          username: username,
                          fullName: fullName,
                          phoneNumber: phoneNumber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  TextFormField _usernameTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        labelText: "Username",
        hintText: "Please enter your username",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Username field can not be empty!";
        } else if (value.trim().length < 4 || value.trim().length > 15) {
          return "Username can be at least 4 and most 15 chars.";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          username = value.toString();
        });
      },
    );
  }

  TextFormField _phoneNumberTextField() {
    return TextFormField(
      initialValue: '+905',
      keyboardType: TextInputType.number,
      inputFormatters: [LengthLimitingTextInputFormatter(13)],
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.phone),
        labelText: "Phone number",
        hintText: "Please enter your mobile phone number",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Phone number field can not be empty!";
        } else if (value.trim().length != 13) {
          return "Phone number should consist of 13 digits with the country code.";
        } else if (value.contains(RegExp(r'[,. ]'))) {
          return "Only numbers";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          phoneNumber = value.toString();
        });
      },
    );
  }

  TextFormField _fullNameTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: "Full Name",
        hintText: "Please enter your full name",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Full name field can not be empty!";
        } else if (value.trim().length < 4) {
          return "Full name should be at least 4 characters.";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          fullName = value.toString();
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

class CompleteButton extends StatelessWidget {
  const CompleteButton(
      {Key? key,
      required this.context,
      required this.formKey,
      required this.id,
      required this.username,
      required this.fullName,
      required this.phoneNumber})
      : super(key: key);

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final String id, username, fullName, phoneNumber;

  @override
  Widget build(BuildContext context) {
    var isUsernameNull = username.isEmpty;
    var isFullNameNull = fullName.isEmpty;
    var isPhoneNumberNull = phoneNumber.isEmpty;
    var result = isUsernameNull || isFullNameNull || isPhoneNumberNull;
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
                _updateUser();
              },
        child: const Text(
          "Complete",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void _updateUser() async {
    final AuthService _authService = AuthService();
    var _formState = formKey.currentState;
    if (_formState!.validate()) {
      _formState.save();

      await _authService
          .updateUser(id, username, fullName, phoneNumber)
          .then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Direct()),
            (route) => false);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      });
    }
  }
}
