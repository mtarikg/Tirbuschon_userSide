import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _storageRef = FirebaseStorage.instance.ref();
  late String imageID;

  Future<String> uploadImage(String userID, File image) async {
    imageID = const Uuid().v4();
    final uploadTask =
        _storageRef.child('profileImages/$userID/$imageID').putFile(image);
    final taskSnapshot = await uploadTask;
    String uploadedImageURL = await taskSnapshot.ref.getDownloadURL();
    return uploadedImageURL;
  }

  Future<List<Map<String, dynamic>>> getVenueGallery(String venueID) async {
    List<Map<String, dynamic>> images = [];

    final result = await _storageRef.storage.ref('venuePhotos/$venueID').list();
    final files = result.items;

    await Future.forEach<Reference>(files, (file) async {
      final String fileUrl = await file.getDownloadURL();

      images.add({
        "url": fileUrl,
        "path": file.fullPath,
      });
    });

    return images;
  }
}
