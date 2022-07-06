import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestoreService.dart';
import '../Core/User/ProfilePages/uploadProfileImagePage.dart';
import '../welcomePage.dart';
import '../Core/User/BottomNavigationBarPages/mainPage.dart';
import '../services/authService.dart';

class NavigatorButtonCard extends StatefulWidget {
  final String text;
  final dynamic pageToNavigate;

  const NavigatorButtonCard({Key? key, required this.text, this.pageToNavigate})
      : super(key: key);

  @override
  State<NavigatorButtonCard> createState() => _NavigatorButtonCardState();
}

class _NavigatorButtonCardState extends State<NavigatorButtonCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
            onPressed: () {
              var lowerCaseText = widget.text.toLowerCase();
              var user = FirebaseAuth.instance.currentUser;
              var userID = user!.uid;

              if (lowerCaseText.contains("username")) {
                _changeUsername(context, userID);
              } else if (lowerCaseText.contains("full name")) {
                _changeFullName(context, userID);
              } else if (lowerCaseText.contains("phone number")) {
                _changePhoneNumber(context, userID);
              } else if (lowerCaseText.contains("profile image")) {
                _changeProfileImage(context, userID);
              } else if (lowerCaseText.contains("delete account")) {
                _deleteAccount(context, userID);
              }

              widget.pageToNavigate == null
                  ? null
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => widget.pageToNavigate));
            },
            child: Text(widget.text,
                style: const TextStyle(color: Colors.white, fontSize: 20))),
      ),
    );
  }

  void _changePhoneNumber(BuildContext context, String userID) {
    final _formKey = GlobalKey<FormState>();
    late String phoneNumberValue = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Phone Number"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              initialValue: '+905',
              keyboardType: TextInputType.number,
              inputFormatters: [LengthLimitingTextInputFormatter(13)],
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                  hintText: "Please enter your new phone number."),
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
                  phoneNumberValue = value;
                });
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  var formState = _formKey.currentState!;
                  if (formState.validate()) {
                    await FirestoreService().updateUserField(
                        userID, 'phoneNumber', phoneNumberValue);

                    var alert = AlertDialog(
                      title: const Text("Change Successful"),
                      content: const Text(
                          "Phone number has been changed successfully."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainPage(index: 2)),
                                  (route) => false);
                            },
                            child: const Text("OK"))
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  } else {
                    var alert = AlertDialog(
                      title: const Text("Change Unsuccessful"),
                      content: const Text("Phone number has not changed."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"))
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  }
                },
                child: const Text("OK"))
          ],
        );
      },
    );
  }

  void _changeUsername(BuildContext context, String userID) {
    final _formKey = GlobalKey<FormState>();
    late String usernameValue = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Username"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                  hintText: "Please enter your new username."),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Username field can not be empty!";
                } else if (value.trim().length < 4 ||
                    value.trim().length > 15) {
                  return "Username can be at least 4 and most 15 chars.";
                }

                return null;
              },
              onChanged: (value) {
                setState(() {
                  usernameValue = value;
                });
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  var formState = _formKey.currentState!;
                  if (formState.validate()) {
                    await FirestoreService()
                        .updateUserField(userID, 'username', usernameValue);

                    var alert = AlertDialog(
                      title: const Text("Change Successful"),
                      content:
                          const Text("Username has been changed successfully."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainPage(index: 2)),
                                  (route) => false);
                            },
                            child: const Text("OK"))
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  } else {
                    var alert = AlertDialog(
                      title: const Text("Change Unsuccessful"),
                      content: const Text("Username has not changed."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"))
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  }
                },
                child: const Text("OK"))
          ],
        );
      },
    );
  }

  void _changeFullName(BuildContext context, String userID) {
    final _formKey = GlobalKey<FormState>();
    late String fullNameValue = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Full Name"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                  hintText: "Please enter your new full name."),
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
                  fullNameValue = value;
                });
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  var formState = _formKey.currentState!;
                  if (formState.validate()) {
                    await FirestoreService()
                        .updateUserField(userID, 'fullName', fullNameValue);

                    var alert = AlertDialog(
                      title: const Text("Change Successful"),
                      content: const Text(
                          "Full Name has been changed successfully."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainPage(index: 2)),
                                  (route) => false);
                            },
                            child: const Text("OK"))
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  } else {
                    var alert = AlertDialog(
                      title: const Text("Change Unsuccessful"),
                      content: const Text("Full name has not changed."),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"))
                      ],
                    );
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => alert);
                  }
                },
                child: const Text("OK"))
          ],
        );
      },
    );
  }

  void _changeProfileImage(BuildContext context, String userID) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UploadProfileImage(userID: userID)));
  }

  void _deleteAccount(BuildContext context, String userID) {
    final AuthService _authService = AuthService();

    showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Account Deleted"),
                content: const Text("Your account has been deleted."),
                actions: [
                  TextButton(
                      onPressed: () {
                        var user = FirebaseAuth.instance.currentUser;
                        _authService.signOut();
                        FirestoreService().deleteUser(userID);
                        user!.delete();
                        Navigator.of(context).pop();
                      },
                      child: const Text("OK"))
                ],
              );
            })
        .then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const WelcomePage()),
            (route) => false));
  }
}
