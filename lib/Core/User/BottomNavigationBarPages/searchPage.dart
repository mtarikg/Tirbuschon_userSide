import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import '../../Shared/userService.dart';
import '../../../services/firestoreService.dart';
import 'mainPage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchResult = [];
  String? searchValue = '';
  String venueType = '';
  String countryValue = '';
  String? districtValue = '';
  String? cityValue = '';
  TextEditingController searchController = TextEditingController();

  getVenues() async {
    var venuesData = await FirestoreService().getAllVenues();

    return venuesData;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: RefreshIndicator(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 150,
          child: Column(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _searchTextField(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CSCPicker(
                            showStates: true,
                            showCities: true,
                            flagState: CountryFlag.DISABLE,
                            dropdownDecoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: Colors.white,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1)),
                            disabledDropdownDecoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                color: Colors.grey.shade300,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1)),
                            stateSearchPlaceholder: "City",
                            citySearchPlaceholder: "District",
                            stateDropdownLabel: "*City",
                            cityDropdownLabel: "*District",
                            defaultCountry: DefaultCountry.Turkey,
                            disableCountry: true,
                            selectedItemStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            dropdownHeadingStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                            dropdownItemStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            dropdownDialogRadius: 10.0,
                            searchBarRadius: 10.0,
                            onCountryChanged: (value) {
                              setState(() {
                                countryValue = value.toString();
                              });
                            },
                            onStateChanged: (value) {
                              setState(() {
                                cityValue = value
                                    .toString()
                                    .replaceAll(" ", "")
                                    .replaceAll("Province", "")
                                    .toString();
                              });
                            },
                            onCityChanged: (value) {
                              setState(() {
                                districtValue = value
                                    .toString()
                                    .replaceAll(" ", "")
                                    .replaceAll("İlçesi", "")
                                    .toString();
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(flex: 2, child: _venueTypeDropdown()),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                            onPressed: () {
                              if (cityValue == "null") {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Please select a city!"),
                                ));
                              } else if (districtValue == "null") {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Please select a district!"),
                                ));
                              } else if (venueType == "") {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Please select a venue type!"),
                                ));
                              } else {
                                _searchVenueByCityDistrict(cityValue.toString(),
                                    districtValue.toString(), venueType);
                              }
                            },
                            child: const Text("Search")),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Expanded(
                child: searchResult.isEmpty
                    ? FutureBuilder(
                        future: getVenues(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasData) {
                            return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, int index) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.5, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              UserService().viewDetails(
                                                  context,
                                                  snapshot.data![index]
                                                      ["Venue Name"]);
                                            },
                                            child: Row(
                                              children: [
                                                snapshot.data![index]
                                                            ["imageUrl"] ==
                                                        null
                                                    ? Padding(
                                                  padding:
                                                  const EdgeInsets.all(10),
                                                  child: Container(
                                                      width: 125,
                                                      height: 125,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey),
                                                      ),
                                                      child: Image.asset(
                                                          'assets/reservationIconPlaceholder.jpg')),
                                                )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Container(
                                                          width: 125,
                                                          height: 125,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          child: Image.network(
                                                            snapshot.data![
                                                                    index]
                                                                ["imageUrl"],
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                Expanded(
                                                  child: Text(
                                                    snapshot.data![index]
                                                        ["Venue Name"],
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  );
                                });
                          }

                          return const Text(
                              "No venue available for the moment.");
                        },
                      )
                    : ListView.builder(
                        itemCount: searchResult.length,
                        itemBuilder: (context, int index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Flexible(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        UserService().viewDetails(context,
                                            searchResult[index]["Venue Name"]);
                                      },
                                      child: Row(
                                        children: [
                                          searchResult[index]["imageUrl"] ==
                                                  null
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                      width: 125,
                                                      height: 125,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey),
                                                      ),
                                                      child: Image.asset(
                                                          'assets/reservationIconPlaceholder.jpg')),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Container(
                                                    width: 125,
                                                    height: 125,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.grey),
                                                    ),
                                                    child: Image.network(
                                                      searchResult[index]
                                                          ["imageUrl"],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                          Expanded(
                                            child: Text(
                                                searchResult[index]
                                                    ["Venue Name"],
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                          );
                        }),
              ),
            ],
          ),
        ),
      ),
      onRefresh: _refreshSearch,
    )));
  }

  Widget _venueTypeDropdown() {
    return DropdownButtonFormField<String>(
      hint: const Text('Venue Type'),
      decoration: const InputDecoration(enabledBorder: InputBorder.none),
      onChanged: (String? newValue) {
        setState(() {
          venueType = newValue!;
        });
      },
      items: <String>['Restaurant', 'Concert Hall', 'Theater']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  TextField _searchTextField() {
    return TextField(
      decoration: InputDecoration(
        suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () {
              if (searchValue == "") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please enter a venue name!"),
                ));
              } else {
                _searchVenueByName(searchValue.toString());
              }
            }),
        labelText: "Search venues",
        hintText: "Please enter name of a venue",
      ),
      onChanged: (value) {
        setState(() {
          searchValue = value.toString();
        });
      },
    );
  }

  Future<void> _searchVenueByName(String value) async {
    var result = await FirestoreService().getVenuesByName(value);

    if (result != null) {
      for (var element in result) {
        var isExist = false;

        for (var item in searchResult) {
          if (item["Address"] == element["Address"]) {
            isExist = true;
            break;
          }
        }

        if (!isExist) {
          setState(() {
            searchResult.clear();
            searchResult.add(element);
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("There is no venue available for the given name."),
      ));

      setState(() {
        searchResult.clear();
      });
    }
  }

  Future<void> _searchVenueByCityDistrict(
      String city, String district, String venueType) async {
    searchResult.clear();
    var result = await FirestoreService()
        .getVenuesByCityDistrictType(city, district, venueType);

    if (result != null) {
      for (var element in result) {
        var isExist = false;

        for (var item in searchResult) {
          if (item["Address"] == element["Address"]) {
            isExist = true;
            break;
          }
        }

        if (!isExist) {
          setState(() {
            searchResult.add(element);
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "There is no venue available for the given city-district-venue type."),
      ));

      setState(() {
        searchResult.clear();
      });
    }
  }

  Future<void> _refreshSearch() async {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage(index: 1)),
        (route) => false);
  }
}
