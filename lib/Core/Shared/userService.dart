import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../User/Review/reviewVenuePage.dart';
import '../User/SearchPages/viewVenue.dart';
import '../../services/firestoreService.dart';

class UserService {
  Future<Position> getUserCurrentPosition() async {
    Position currentPosition;

    var result = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = result;

    return currentPosition;
  }

  Future<List<String>> getUserCurrentAddressData() async {
    Position position = await getUserCurrentPosition();
    List<Placemark> p =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = p[0];
    List<String> currentAddressData = [];
    currentAddressData.add(place.administrativeArea.toString());
    currentAddressData.add(place.subAdministrativeArea.toString());

    return currentAddressData;
  }

  void viewDetails(BuildContext context, String venueName) async {
    var venueID = await FirestoreService().getVenueIDByName(venueName);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewVenue(venueID: venueID.toString())));
  }

  void reservationDetail(
      BuildContext context, QueryDocumentSnapshot<Object?> snapshotDoc) async {
    var venueData =
        await FirestoreService().getVenueByID(snapshotDoc["Venue ID"]);

    var reviewData = await FirestoreService()
        .getReviewByReservationID(snapshotDoc["Reservation ID"]);

    var venueImage = venueData["imageUrl"];
    var venueName = venueData["Venue Name"];
    var capacity = snapshotDoc["Party Size"].toString();
    var totalPrice = snapshotDoc["Total Price"].toString();
    var reservationDate = DateTime.parse(
        (snapshotDoc["Reservation Date"] as Timestamp).toDate().toString());
    var formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(reservationDate);
    var hasReview = false;
    var rating = 0;
    var comment = "";
    var postReservation = DateTime.now().compareTo(reservationDate) == 1;

    if (reviewData != null) {
      rating = reviewData["Rating"];
      comment = reviewData["Comment"];
    }

    if (rating != 0) {
      hasReview = true;
    }

    TextButton _backToProfilePageButton(BuildContext context) {
      return TextButton(
          onPressed: () => Navigator.pop(context), child: const Text("Back"));
    }

    TextButton _addReview(
        BuildContext context, String reservationID, String venueName) {
      return TextButton(
          child: const Text("Add a review!"),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReviewVenue(
                        venueName: venueName, reservation: reservationID)));
          });
    }

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AlertDialog(
          title: const Center(child: Text("Reservation Detail")),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (venueImage != null) ...[
                ReservationDetailImageContainer(
                    context: context, imageURL: venueImage),
              ],
              const SizedBox(height: 40),
              Flexible(
                child: Column(
                  children: [
                    _ReservationDetailContainer(
                        iconData: Icons.location_on, text: venueName),
                    const SizedBox(height: 40),
                    _ReservationDetailContainer(
                        iconData: Icons.person, text: capacity),
                    const SizedBox(height: 40),
                    _ReservationDetailContainer(
                        iconData: Icons.price_check, text: totalPrice),
                    const SizedBox(height: 40),
                    _ReservationDetailContainer(
                        iconData: Icons.date_range, text: formattedDate),
                    if (hasReview) ...[
                      const SizedBox(height: 40),
                      _ReservationDetailContainer(
                          iconData: Icons.star, text: rating.toString()),
                      if (comment != "") ...[
                        const SizedBox(height: 40),
                        _ReservationDetailContainer(
                            iconData: Icons.comment, text: comment),
                      ]
                    ]
                  ],
                ),
              )
            ],
          ),
          actions: [
            if (!hasReview /*&& postReservation*/) ...[
              _addReview(context, snapshotDoc["Reservation ID"], venueName),
            ],
            _backToProfilePageButton(context)
          ],
        ),
      ),
    );
  }
}

class ReservationDetailImageContainer extends StatelessWidget {
  final BuildContext context;
  final String imageURL;

  const ReservationDetailImageContainer({
    Key? key,
    required this.imageURL,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width - 30,
        height: 250,
        decoration:
            BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
        child: Image.network(
          imageURL,
          fit: BoxFit.fill,
        ));
  }
}

class _ReservationDetailContainer extends StatelessWidget {
  final IconData iconData;
  final String text;

  const _ReservationDetailContainer({
    required this.iconData,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.grey))),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Icon(iconData),
          const SizedBox(width: 5),
          Flexible(child: Text(text.toString())),
        ],
      ),
    );
  }
}
