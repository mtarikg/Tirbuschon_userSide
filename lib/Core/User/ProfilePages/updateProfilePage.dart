import 'package:flutter/material.dart';
import '../../../MyWidgets/navigatorButtonCard.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key}) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Profile"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 20,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            NavigatorButtonCard(text: "Change Username"),
            NavigatorButtonCard(text: "Change Full Name"),
            NavigatorButtonCard(text: "Change Phone Number"),
            NavigatorButtonCard(text: "Change Profile Image"),
          ],
        ));
  }
}
