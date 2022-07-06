import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../BottomNavigationBarPages/mainPage.dart';
import '../../../services/firestoreService.dart';

class Payment extends StatefulWidget {
  final String venueID;
  final int partySize;
  final DateTime selectedDate;

  const Payment(
      {Key? key,
      required this.venueID,
      required this.selectedDate,
      required this.partySize})
      : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiredDateController = TextEditingController();
  late String cardHolder = "", cardNumber = "", expiredDate = "", cvv = "";
  late double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    totalPrice = 150.0 * (widget.partySize);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
          key: _formKey,
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 30,
            width: MediaQuery.of(context).size.width,
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _cardHolderTextField(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _cardNumberTextField(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _cardExpiredDateTextField(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: _cardCVVTextField(),
                      ),
                      const SizedBox(height: 30),
                      Text("Total Price: $totalPrice₺",
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      CompleteButton(
                          context: context,
                          formKey: _formKey,
                          id: widget.venueID,
                          partySize: widget.partySize,
                          selectedDate: widget.selectedDate,
                          price: totalPrice,
                          cardHolder: cardHolder,
                          cardNumber: cardNumber,
                          expiredDate: expiredDate,
                          cvv: cvv),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  TextFormField _cardHolderTextField() {
    return TextFormField(
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        labelText: "Card Holder",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Card holder can not be empty!";
        }

        if (!value.contains(RegExp(r'^[a-zA-Z ]*$'))) {
          return "Card holder name should consist of four alphabetic characters!";
        }

        return null;
      },
      onChanged: (value) {
        setState(() {
          cardHolder = value.toString();
        });
      },
    );
  }

  TextFormField _cardNumberTextField() {
    return TextFormField(
      controller: _cardNumberController,
      keyboardType: TextInputType.number,
      inputFormatters: [LengthLimitingTextInputFormatter(19)],
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.numbers),
        labelText: "Card number",
        hintText: "XXXX XXXX XXXX XXXX",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Card number field can not be empty!";
        } else if (value.replaceAll(" ", "").length != 16) {
          return "Card number should consist of 16 digits.";
        } else if (!value.contains(RegExp(r'^[0-9 ]+$'))) {
          return "Only numbers";
        }
        return null;
      },
      onChanged: (value) {
        if (value.contains(RegExp(r'[0-9]')) &&
            value.replaceAll(" ", "").length % 4 == 0 &&
            value.length != 19) {
          value += " ";
          _cardNumberController.value = TextEditingValue(
            text: value.toString(),
            selection: TextSelection.collapsed(offset: value.length),
          );
        }

        setState(() {
          cardNumber = value.toString();
        });
      },
    );
  }

  TextFormField _cardExpiredDateTextField() {
    return TextFormField(
      controller: _expiredDateController,
      keyboardType: TextInputType.number,
      inputFormatters: [LengthLimitingTextInputFormatter(5)],
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.numbers),
        labelText: "Expired Date",
        hintText: "XX/XX ",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "Expired date can not be empty!";
        } else if (value.trim().length != 5) {
          return "Expired date should consist of a month and a year value.";
        } else if (value.contains(RegExp(r'[,. ]'))) {
          return "Only numbers";
        } else if (int.parse(value.substring(0, 2)) > 12 ||
            int.parse(value.substring(3, 5).toString()) <
                int.parse(DateTime.now().year.toString().substring(2, 4))) {
          return "Enter a valid expiry date!";
        }
        return null;
      },
      onChanged: (value) {
        if (value.length == 2 && !value.contains("/")) {
          value = (value + "/").toString();
          _expiredDateController.value = TextEditingValue(
            text: value.toString(),
            selection: TextSelection.collapsed(offset: value.length),
          );
        }

        setState(() {
          expiredDate = value.toString();
        });
      },
    );
  }

  TextFormField _cardCVVTextField() {
    return TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [LengthLimitingTextInputFormatter(3)],
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.numbers),
        labelText: "CVV",
        hintText: "XXX",
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "CVV can not be empty!";
        } else if (value.trim().length != 3) {
          return "Card number should consist of 3 digits.";
        } else if (!value.contains(RegExp(r'^[0-9]+$'))) {
          return "Only numbers";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          cvv = value.toString();
        });
      },
    );
  }
}

class CompleteButton extends StatelessWidget {
  const CompleteButton(
      {Key? key,
      required this.context,
      required this.formKey,
      required this.id,
      required this.partySize,
      required this.selectedDate,
      required this.price,
      required this.cardHolder,
      required this.cardNumber,
      required this.expiredDate,
      required this.cvv})
      : super(key: key);

  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final String id, cardHolder, cardNumber, expiredDate, cvv;
  final int partySize;
  final DateTime selectedDate;
  final double price;

  @override
  Widget build(BuildContext context) {
    var isCardHolderNull = cardHolder.isEmpty;
    var isCardNumberNull = cardNumber.isEmpty;
    var isExpiredDateNull = expiredDate.isEmpty;
    var isCVVNull = cvv.isEmpty;
    var result =
        isCardHolderNull || isCardNumberNull || isExpiredDateNull || isCVVNull;
    var isDisabled = result;

    return Container(
      width: MediaQuery.of(context).size.width - 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(width: 1),
        color: isDisabled ? Colors.grey : Colors.blue,
      ),
      child: TextButton(
          onPressed: isDisabled
              ? null
              : () {
                  _completeReservation(id, selectedDate, price);
                },
          child: const Text(
            "Complete",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          )),
    );
  }

  void _completeReservation(
      String venueID, DateTime selectedDate, double price) async {
    var _formState = formKey.currentState;

    if (_formState!.validate()) {
      _formState.save();

      var userID = FirebaseAuth.instance.currentUser!.uid.toString();
      var result = await FirestoreService()
          .makeReservation(userID, venueID, partySize, selectedDate, price);

      if (result) {
        var duration = const Duration(seconds: 2);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("You've made a reservation successfully."),
          duration: duration,
        ));

        Future.delayed(duration, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MainPage(index: 2)));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong while making a reservation."),
        ));
      }
    }
  }
}
