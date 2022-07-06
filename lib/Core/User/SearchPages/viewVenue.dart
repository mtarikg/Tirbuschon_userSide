import 'package:flutter/material.dart';
import 'package:tirbuschon_feng497/Core/User/SearchPages/venueGallery.dart';
import '../ReservationPages/reservationDetails.dart';
import 'venueReviews.dart';
import '../../../MyWidgets/navigatorButtonCard.dart';
import '../../../services/firestoreService.dart';
import 'googleMaps.dart';
import 'menuPage.dart';

class ViewVenue extends StatefulWidget {
  final String venueID;

  const ViewVenue({
    Key? key,
    required this.venueID,
  }) : super(key: key);

  @override
  State<ViewVenue> createState() => _ViewVenueState();
}

class _ViewVenueState extends State<ViewVenue> {
  getVenueInfo() async {
    dynamic venueData = await FirestoreService().getVenueByID(widget.venueID);

    return venueData;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Venue Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: FutureBuilder(
            future: getVenueInfo(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (snapshot.data.containsKey("imageUrl")) ...[
                        _VenueProfileImageContainer(
                            imageURL: snapshot.data["imageUrl"]),
                      ] else ...[
                        _VenueProfileImageContainer(imageURL: null.toString()),
                      ],
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              _VenueInfoContainer(
                                  value: snapshot.data["Venue Name"],
                                  boldOption: true),
                              _VenueInfoContainer(
                                  value: snapshot.data["Phone"],
                                  boldOption: false),
                              _VenueInfoContainer(
                                  value: snapshot.data["Address"],
                                  boldOption: false),
                              _VenueInfoContainer(
                                  title: "Capacity",
                                  value: snapshot.data["Capacity"],
                                  boldOption: false),
                              _VenueInfoContainer(
                                  title: "Current Reservation Capacity",
                                  value: snapshot.data["Reservation Capacity"],
                                  boldOption: false),
                              NavigatorButtonCard(
                                  pageToNavigate: MapView(
                                      venueAddress: snapshot.data["Address"]),
                                  text: "Show Location"),
                              NavigatorButtonCard(
                                  pageToNavigate: MenuPage(
                                    venueID: widget.venueID,
                                    venueName: snapshot.data["Venue Name"],
                                  ),
                                  text: "See Menu"),
                              NavigatorButtonCard(
                                  pageToNavigate: VenueGallery(
                                    venueID: widget.venueID,
                                  ),
                                  text: "View Gallery"),
                              if (snapshot.data["Reservation Capacity"] !=
                                  "0") ...[
                                NavigatorButtonCard(
                                    pageToNavigate: ReservationDetails(
                                        venueID: widget.venueID),
                                    text: "Quick Reservation"),
                              ],
                              NavigatorButtonCard(
                                  pageToNavigate:
                                      VenueReviews(venueID: widget.venueID),
                                  text: "See Reviews"),
                            ],
                          )),
                    ],
                  ),
                );
              }

              return const Center(
                child:
                    Text("Venue data is not available for the current moment."),
              );
            },
          ))
        ],
      ),
    );
  }
}

class _VenueProfileImageContainer extends StatelessWidget {
  final String imageURL;

  const _VenueProfileImageContainer({Key? key, required this.imageURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return imageURL == "null"
        ? Center(
            child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 150,
                child: Center(
                  child: Image.asset('assets/reservationIconPlaceholder.jpg'),
                )),
          ))
        : Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 150,
                child: Center(
                  child: Image.network(imageURL),
                )),
          );
  }
}

class _VenueInfoContainer extends StatelessWidget {
  final String? title;
  final String value;
  final bool boldOption;

  const _VenueInfoContainer(
      {this.title, required this.value, required this.boldOption, Key? key})
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
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          title == null ? value : "$title : $value",
          style: boldOption
              ? const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold)
              : const TextStyle(fontSize: 17, color: Colors.black87),
        ),
      )),
    );
  }
}
