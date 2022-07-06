import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  Future<List?> getAllVenues() async {
    final QuerySnapshot qs = await _firestore.collection("Venues").get();
    var venuesList = [];

    if (qs.docs.isNotEmpty) {
      for (var doc in qs.docs) {
        var profileInfo = await doc.reference
            .collection("Profile Information")
            .get()
            .then((value) => value.docs[0].data());
        venuesList.add(profileInfo);
      }

      return venuesList;
    }

    return null;
  }

  Future<List?> getVenuesByCityDistrictType(
      String city, String district, String venueType) async {
    var venuesList = [];

    final QuerySnapshot qs = await _firestore
        .collection("Venues")
        .where("City", isEqualTo: city)
        .where("District", isEqualTo: district)
        .where("Venue Type", isEqualTo: venueType)
        .get();

    if (qs.docs.isNotEmpty) {
      for (var doc in qs.docs) {
        var profileInfo = await doc.reference
            .collection("Profile Information")
            .get()
            .then((value) => value.docs[0].data());
        venuesList.add(profileInfo);
      }

      return venuesList;
    }

    return null;
  }

  Future<List?> getVenuesByName(String venueName) async {
    var venuesList = [];

    final QuerySnapshot qs = await _firestore
        .collection("Venues")
        .where("Venue", isEqualTo: venueName)
        .get();

    if (qs.docs.isNotEmpty) {
      for (var doc in qs.docs) {
        var profileInfo = await doc.reference
            .collection("Profile Information")
            .get()
            .then((value) => value.docs[0].data());
        venuesList.add(profileInfo);
      }

      return venuesList;
    }

    return null;
  }

  Future<dynamic> getVenueByID(String venueID) async {
    final venue = await _firestore
        .collection("Venues")
        .doc(venueID)
        .collection("Profile Information")
        .get()
        .then((value) => value.docs[0].data());

    return venue;
  }

  Future<String?> getVenueIDByName(String venueName) async {
    final QuerySnapshot qs = await _firestore
        .collection("Venues")
        .where("Venue", isEqualTo: venueName)
        .get();

    if (qs.docs.isNotEmpty) {
      return qs.docs[0].id;
    }

    return null;
  }

  Future<dynamic> getMenu(String venueID) async {
    final QuerySnapshot qs = await _firestore
        .collection("Venues")
        .doc(venueID)
        .collection("Menu")
        .get();

    if (qs.docs.isNotEmpty) {
      return qs.docs[0];
    }

    return null;
  }

  Future<bool> makeReservation(String userID, String venueID, int partySize,
      DateTime selectedDate, double price) async {
    var reservationResult = false;
    var capacityResult = false;

    final QuerySnapshot qs = await _firestore
        .collection("Venues")
        .doc(venueID)
        .collection("Profile Information")
        .get();

    if (qs.docs.isNotEmpty) {
      var subCollectionID = qs.docs[0].id;

      var reservationCapacity = await _firestore
          .collection("Venues")
          .doc(venueID)
          .collection("Profile Information")
          .doc(subCollectionID)
          .get()
          .then((value) => value.data()!["Reservation Capacity"]);

      int newValue = int.parse(reservationCapacity);

      if (newValue != 0) {
        newValue = newValue - 1;

        await _firestore
            .collection("Venues")
            .doc(venueID)
            .collection("Profile Information")
            .doc(subCollectionID)
            .update({"Reservation Capacity": newValue.toString()});
        capacityResult = true;
      } else {
        return reservationResult;
      }
    }

    if (capacityResult) {
      var reservationID = const Uuid().v4();
      var createdDate = DateTime.now();

      await _firestore
          .collection("Venues")
          .doc(venueID)
          .collection("Reservations")
          .doc(reservationID)
          .set({
        "Party Size": partySize,
        "Reservation ID": reservationID,
        "User ID": userID,
        "Created Date": createdDate,
        "Reservation Date": selectedDate,
        "Total Price": price
      });

      await _firestore
          .collection("Users")
          .doc(userID)
          .collection("Reservations List")
          .doc(reservationID)
          .set({
        "Party Size": partySize,
        "Reservation ID": reservationID,
        "Venue ID": venueID,
        "Created Date": createdDate,
        "Reservation Date": selectedDate,
        "Total Price": price
      });

      reservationResult = true;
    }

    return reservationResult;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserReservations() {
    var user = FirebaseAuth.instance.currentUser;
    var userID = user!.uid;
    var snapshots = _firestore
        .collection("Users")
        .doc(userID)
        .collection("Reservations List")
        .orderBy("Reservation Date", descending: true)
        .snapshots();

    return snapshots;
  }

  Future<bool> addReview(String userID, String venueID, String reservationID,
      int rating, String? comment) async {
    var userSideResult = false;
    var venueSideResult = false;

    var reviewID = const Uuid().v4();
    var createdDate = DateTime.now();

    await _firestore
        .collection("Users")
        .doc(userID)
        .collection("Reviews List")
        .doc(reviewID)
        .set({
      "User ID": userID,
      "Reservation ID": reservationID,
      "Review ID": reviewID,
      "Rating": rating,
      "Comment": comment,
      "Created Date": createdDate
    }).then((value) => {userSideResult = true});

    await _firestore
        .collection("Venues")
        .doc(venueID)
        .collection("Reviews")
        .doc(reviewID)
        .set({
      "User ID": userID,
      "Reservation ID": reservationID,
      "Review ID": reviewID,
      "Rating": rating,
      "Comment": comment,
      "Created Date": createdDate
    }).then((value) => {venueSideResult = true});

    var result = userSideResult && venueSideResult;
    return result;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getVenueReviews(String venueID) {
    var snapshots = _firestore
        .collection("Venues")
        .doc(venueID)
        .collection("Reviews")
        .orderBy("Created Date", descending: true)
        .snapshots();

    return snapshots;
  }

  Future<dynamic> getReviewByReservationID(String reservationID) async {
    var user = FirebaseAuth.instance.currentUser;
    var userID = user!.uid;

    var reviewsCollection = await _firestore
        .collection("Users")
        .doc(userID)
        .collection("Reviews List")
        .get();

    for (var doc in reviewsCollection.docs) {
      if (doc["Reservation ID"] == reservationID) {
        return doc;
      }
    }

    return null;
  }

  Future<bool> userExists(String userID) async {
    var existingUser = false;

    await _firestore
        .collection('Users')
        .doc(userID)
        .collection("profileInfo")
        .get()
        .then((value) => existingUser = value.docs.isNotEmpty);
    return existingUser;
  }

  Future<String?> getUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    var currentUser = _auth.currentUser;
    var currentUserID = currentUser!.uid;

    var userDocument =
        await _firestore.collection('Users').doc(currentUserID).get();

    if (userDocument.exists) {
      return "Users";
    }

    var venueDocument =
        await _firestore.collection('Venues').doc(currentUserID).get();

    if (venueDocument.exists) {
      return "Venues";
    }

    var adminDocument =
        await _firestore.collection('Admin').doc(currentUserID).get();

    if (adminDocument.exists) {
      return "Admin";
    }

    return null;
  }

  Future<String> getProfileInfo(String userID, String text) async {
    var result = await _firestore
        .collection('Users')
        .doc(userID)
        .collection('profileInfo')
        .get()
        .then((value) => value.docs[0].data()[text]);
    var userData = result.toString();

    return userData;
  }

  Future<void> uploadImage(String userID, String imageURL) async {
    var document = await _firestore
        .collection('Users')
        .doc(userID)
        .collection('profileInfo')
        .get();
    await document.docs[0].reference.update({'avatarURL': imageURL});
  }

  Future<void> updateUserField(
      String userID, String userField, String updateValue) async {
    var document = await _firestore
        .collection('Users')
        .doc(userID)
        .collection('profileInfo')
        .get();

    await document.docs[0].reference.update({userField: updateValue});
  }

  Future<void> deleteUser(String userID) async {
    var documentReference = _firestore.collection("Users").doc(userID);
    documentReference
        .collection("profileInfo")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    documentReference
        .collection("Reservations List")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    documentReference
        .collection("Reviews List")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });

    documentReference.delete();
  }
}
