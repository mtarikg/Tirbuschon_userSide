import 'package:flutter/material.dart';
import '../../../MyWidgets/navigatorButtonCard.dart';
import 'updateProfilePage.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile Settings"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 20,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              NavigatorButtonCard(
                  text: "Update Profile", pageToNavigate: UpdateProfilePage()),
              NavigatorButtonCard(text: "Delete Account"),
            ],
          ),
        ));
  }
}
