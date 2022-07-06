import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../services/firestoreService.dart';
import 'package:timeago/timeago.dart' as timeago;

class VenueReviews extends StatefulWidget {
  final String venueID;

  const VenueReviews({Key? key, required this.venueID}) : super(key: key);

  @override
  State<VenueReviews> createState() => _VenueReviewsState();
}

class _VenueReviewsState extends State<VenueReviews> {
  @override
  void initState() {
    super.initState();
  }

  getUsername(String userID) async {
    var usernameValue =
        await FirestoreService().getProfileInfo(userID, "username");

    return usernameValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: StreamBuilder(
          stream: FirestoreService().getVenueReviews(widget.venueID),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.docs.isNotEmpty
                  ? ListView(
                      children: snapshot.data!.docs
                          .map((e) => FutureBuilder(
                                future: getUsername(e['User ID']),
                                builder: (BuildContext context,
                                    AsyncSnapshot<dynamic> secondSnapshot) {
                                  if (secondSnapshot.hasData) {
                                    return ListTile(
                                      title: createReview(
                                          user: secondSnapshot.data,
                                          comment: e['Comment'].toString(),
                                          rate: e['Rating'],
                                          date: (e['Created Date'] as Timestamp)
                                              .toDate()),
                                    );
                                  }

                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              ))
                          .toList())
                  : const Center(
                      child: Text("No reviews made yet for this venue!"));
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget createReview({user, rate, comment, date}) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShowRating(rating: rate),
                ShowTimeAgo(createdDate: date),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person),
                Text(
                  user.toString().replaceRange(
                      1, null, "*" * (user.toString().length - 1)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              comment,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowTimeAgo extends StatelessWidget {
  final DateTime createdDate;

  const ShowTimeAgo({Key? key, required this.createdDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String time = "";
    var timeValue = DateTime.parse(createdDate.toString());
    time = timeago.format(timeValue);

    return Text(time);
  }
}

class ShowRating extends StatelessWidget {
  final int rating;

  const ShowRating({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      rating: rating.toDouble(),
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemSize: 20,
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
    );
  }
}
