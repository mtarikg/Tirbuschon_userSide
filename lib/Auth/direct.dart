import 'package:flutter/material.dart';
import '../Admin/adm_bottom_navigation/admin_navigator.dart';
import '../Restaurant/Screens/helper/venue_main_screen.dart';
import '../services/firestoreService.dart';
import '../Core/User/BottomNavigationBarPages/mainPage.dart';
import '../welcomePage.dart';

class Direct extends StatelessWidget {
  const Direct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUser(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            if (snapshot.data == "Users") {
              return const MainPage();
            } else if (snapshot.data == "Venues") {
              return const VenueMainScreen();
            } else if (snapshot.data == "Admin") {
              return const AdminBottomNavBar();
            }
          }

          return const WelcomePage();
        });
  }

  Future<String> getUser() async {
    FirestoreService _firestoreService = FirestoreService();
    var userType = await _firestoreService.getUser();
    return userType.toString();
  }
}
