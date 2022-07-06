import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/firestoreService.dart';
import '../../Shared/userService.dart';
import 'mainPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, top: 50),
            child: Column(
              children: [
                _restaurantsNearbyText(),
                const SizedBox(height: 5),
                _restaurantsNearby(),
                const SizedBox(height: 40),
                _otherVenuesNearbyText(),
                const SizedBox(height: 5),
                _otherVenuesNearby(),
                const SizedBox(height: 40),
                _latestReservationsText(),
                const SizedBox(height: 5),
                _latestReservations()
              ],
            ),
          ),
        ),
      ),
      onRefresh: _refreshHome,
    ));
  }

  Widget _restaurantsNearbyText() {
    return Row(
      children: [
        const Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: Text("Restaurants Nearby:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainPage(index: 1)),
                      (route) => false);
                },
                child: const Text(
                  "All restaurants",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                )),
          ),
        ),
      ],
    );
  }

  Widget _restaurantsNearby() {
    return FutureBuilder<List<dynamic>?>(
        future: getNearbyVenues("Restaurant"),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return SizedBox(
              height: 125,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length.clamp(0, 10),
                    itemBuilder: (context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 7.5),
                        child: InkWell(
                          onTap: () {
                            UserService().viewDetails(
                                context, snapshot.data![index]["Venue Name"]);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              snapshot.data![index]["imageUrl"] == null
                                  ? const SizedBox(width: 100, height: 100)
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.5, color: Colors.grey),
                                      ),
                                      child: Image.network(
                                        snapshot.data![index]["imageUrl"],
                                        fit: BoxFit.cover,
                                      )),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(snapshot.data![index]["Venue Name"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            );
          }

          return const Text("No restaurant nearby");
        });
  }

  Widget _otherVenuesNearbyText() {
    return Row(
      children: [
        const Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: Text("Other Venues Nearby:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainPage(index: 1)),
                      (route) => false);
                },
                child: const Text(
                  "All other venues",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                )),
          ),
        ),
      ],
    );
  }

  Widget _otherVenuesNearby() {
    return FutureBuilder<List<dynamic>?>(
        future: getNearbyVenues("Other"),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return SizedBox(
              height: 125,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length.clamp(0, 10),
                    itemBuilder: (context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 7.5),
                        child: InkWell(
                          onTap: () {
                            UserService().viewDetails(
                                context, snapshot.data![index]["Venue Name"]);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              snapshot.data![index]["imageUrl"] == null
                                  ? const SizedBox(width: 100, height: 100)
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.5, color: Colors.grey),
                                      ),
                                      child: Image.network(
                                        snapshot.data![index]["imageUrl"],
                                        fit: BoxFit.cover,
                                      )),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(snapshot.data![index]["Venue Name"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            );
          }

          return const Text("No venue nearby");
        });
  }

  Widget _latestReservationsText() {
    return Row(
      children: [
        const Expanded(
          child: Align(
              alignment: Alignment.topLeft,
              child: Text("Your latest reservations:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainPage(index: 2)),
                      (route) => false);
                },
                child: const Text(
                  "All reservations",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                )),
          ),
        ),
      ],
    );
  }

  Widget _latestReservations() {
    return StreamBuilder(
        stream: FirestoreService().getUserReservations(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.size != 0
                ? SizedBox(
                    height: 100,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length.clamp(0, 10),
                          itemBuilder: (context, int index) {
                            var snapshotDocs = snapshot.data!.docs;

                            return Padding(
                              padding: const EdgeInsets.only(right: 7.5),
                              child: InkWell(
                                onTap: () {
                                  UserService().reservationDetail(
                                      context, snapshotDocs[index]);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5, color: Colors.grey),
                                        ),
                                        child: Image.asset(
                                            'assets/reservationIconPlaceholder.jpg')),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  )
                : const Text("No reservations made yet!");
          }

          return const Center(child: CircularProgressIndicator());
        });
  }

  Future<List<dynamic>?> getNearbyVenues(String venueType) async {
    List<String> locationData;
    List? nearbyVenues;

    var locationEnabled = await Geolocator.isLocationServiceEnabled();
    var requestResult = await Permission.location.request();

    if (locationEnabled && requestResult.isGranted) {
      locationData = await UserService().getUserCurrentAddressData();
      nearbyVenues = await FirestoreService().getVenuesByCityDistrictType(
          locationData[0], locationData[1], venueType);
    } else if (!locationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enable the location and reload the page!"),
      ));
    } else if (!requestResult.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Give permission to use location services!"),
      ));

      Future.delayed(const Duration(seconds: 3), () {
        openAppSettings();
      });
    }

    return nearbyVenues;
  }

  Future<void> _refreshHome() async {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage(index: 0)),
        (route) => false);
  }
}
