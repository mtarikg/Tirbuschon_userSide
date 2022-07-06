import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Shared/userService.dart';
import '../../../services/firestoreService.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userID = "";

  getUserID() {
    var user = FirebaseAuth.instance.currentUser;
    userID = user!.uid;
  }

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _UserProfileImageContainer(userID: userID),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _profileInfo(context),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 10),
              child: Column(
                children: [_myReservationsText(), _showReservations()],
              ))
        ],
      ),
    );
  }

  Column _profileInfo(BuildContext context) {
    return Column(
      children: [
        _UserInfoContainer(userID: userID, text: "fullName", boldOption: true),
        _UserInfoContainer(userID: userID, text: "username", boldOption: false)
      ],
    );
  }

  Widget _myReservationsText() {
    return const Center(
        child: Text(
      "My Reservations",
      style: TextStyle(
          fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
    ));
  }

  Widget _showReservations() {
    return StreamBuilder(
        stream: FirestoreService().getUserReservations(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.size != 0
                ? GridView.builder(
                    padding: const EdgeInsets.all(10),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      dynamic snapshotDocs = snapshot.data!.docs;

                      return TextButton(
                          onPressed: () {
                            UserService().reservationDetail(
                                context, snapshotDocs[index]);
                          },
                          child: Image.asset(
                              'assets/reservationIconPlaceholder.jpg'));
                    },
                  )
                : const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text("No reservations to list."),
                  );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

class _UserProfileImageContainer extends StatelessWidget {
  final String userID;

  const _UserProfileImageContainer({Key? key, required this.userID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirestoreService().getProfileInfo(userID, "avatarURL"),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == "null") {
          return Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 150,
                child: Center(
                  child: Image.asset('assets/placeholder.jpg'),
                )),
          ));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: Center(
                child: Image.network(snapshot.data),
              )),
        );
      },
    );
  }
}

class _UserInfoContainer extends StatelessWidget {
  final String userID;
  final String text;
  final bool boldOption;

  const _UserInfoContainer(
      {required this.text,
      required this.boldOption,
      Key? key,
      required this.userID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(width: 1, color: Colors.grey),
              bottom: BorderSide(width: 1, color: Colors.grey))),
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Center(
          child: _ProfileInfoFutureBuilder(
              userID: userID, text: text, boldOption: boldOption)),
    );
  }
}

class _ProfileInfoFutureBuilder extends StatelessWidget {
  const _ProfileInfoFutureBuilder({
    Key? key,
    required this.userID,
    required this.text,
    required this.boldOption,
  }) : super(key: key);

  final String userID;
  final String text;
  final bool boldOption;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirestoreService().getProfileInfo(userID, text),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return !snapshot.hasData
            ? const Center(child: CircularProgressIndicator())
            : Text(
                snapshot.data,
                style: boldOption
                    ? const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold)
                    : const TextStyle(fontSize: 17, color: Colors.black87),
              );
      },
    );
  }
}
