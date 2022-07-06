import 'package:flutter/material.dart';
import 'paymentPage.dart';

class ReservationDetails extends StatefulWidget {
  final String venueID;

  const ReservationDetails({Key? key, required this.venueID}) : super(key: key);

  @override
  State<ReservationDetails> createState() => _ReservationDetailsState();
}

class _ReservationDetailsState extends State<ReservationDetails> {
  DateTime baseDate = DateTime.now();
  late DateTime selectedDate;
  int partySize = 1;

  @override
  void initState() {
    super.initState();
    selectedDate = baseDate;
  }

  @override
  Widget build(BuildContext context) {
    final day = selectedDate.day.toString().padLeft(2, "0");
    final month = selectedDate.month.toString().padLeft(2, "0");
    final year = selectedDate.year.toString();
    final hour = selectedDate.hour.toString().padLeft(2, "0");
    final minute = selectedDate.minute.toString().padLeft(2, "0");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservation Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Party Size",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            if (partySize == 1) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content:
                                    Text("Party size should be at least 1."),
                              ));
                            } else {
                              setState(() {
                                partySize--;
                              });
                            }
                          },
                          icon: const Icon(Icons.remove)),
                      Text(partySize == 1
                          ? "$partySize person"
                          : "$partySize people"),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              partySize++;
                            });
                          },
                          icon: const Icon(Icons.add))
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Date",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ElevatedButton(
                    child: Text("$day / $month / $year"),
                    onPressed: () async {
                      final date = await pickDate();

                      if (date == null) {
                        return;
                      }

                      final updatedDateTime = DateTime(date.year, date.month,
                          date.day, selectedDate.hour, selectedDate.minute);

                      setState(() {
                        selectedDate = updatedDateTime;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Time",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ElevatedButton(
                    child: Text("$hour:$minute"),
                    onPressed: () async {
                      final time = await pickTime();
                      DateTime updatedDateTime;

                      if (time == null) {
                        return;
                      }

                      updatedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          time.hour,
                          time.minute);

                      setState(() {
                        selectedDate = updatedDateTime;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 75),
              ElevatedButton(
                child: const Text("Continue to payment"),
                onPressed: selectedDate.compareTo(baseDate) == -1 ||
                        selectedDate.compareTo(baseDate) == 0
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Select a valid time!")));
                      }
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Payment(
                                      venueID: widget.venueID,
                                      partySize: partySize,
                                      selectedDate: selectedDate,
                                    )));
                      },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: baseDate,
      firstDate: DateTime(baseDate.year, baseDate.month, baseDate.day),
      lastDate: DateTime(baseDate.year, baseDate.month, baseDate.day + 7));

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute));
}
