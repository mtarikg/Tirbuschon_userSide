import 'package:flutter/material.dart';
import '../../../services/storageService.dart';

class VenueGallery extends StatelessWidget {
  final String venueID;

  const VenueGallery({Key? key, required this.venueID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gallery")),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _venueGallery(venueID),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: GridView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> image =
                                    snapshot.data![index];

                                return (Image.network(image['url']));
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                              ),
                            ),
                          )
                        : const Center(child: Text("No photo has been added."));
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _venueGallery(String venueID) async {
    var images = await StorageService().getVenueGallery(venueID);

    return images;
  }
}
