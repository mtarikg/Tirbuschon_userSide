import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/firestoreService.dart';
import '../BottomNavigationBarPages/mainPage.dart';
import '../../../services/storageService.dart';

class UploadProfileImage extends StatefulWidget {
  final String userID;

  const UploadProfileImage({Key? key, required this.userID}) : super(key: key);

  @override
  State<UploadProfileImage> createState() => _UploadProfileImageState();
}

class _UploadProfileImageState extends State<UploadProfileImage> {
  bool imageLoaded = false;
  late File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New profile image"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 20,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _postForm(),
    );
  }

  Widget _postForm() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (!imageLoaded
                ? imagePicker()
                : Container(
                    padding: const EdgeInsets.fromLTRB(75, 25, 75, 25),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: file != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                child: Image.file(file!),
                              ),
                              Positioned(
                                right: 0,
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    file = null;
                                  }),
                                  child: const Icon(Icons.clear,
                                      size: 25, color: Colors.white),
                                ),
                              ),
                            ],
                          )
                        : imagePicker())),
            const SizedBox(height: 50),
            SizedBox(
              height: 50,
              width: 250,
              child: ElevatedButton(
                  onPressed: alertUser,
                  child: const Text(
                    "Change profile image",
                    style: TextStyle(fontSize: 20),
                  )),
            )
          ],
        ),
      ),
    );
  }

  selectPhoto() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Create Post"),
            children: [
              SimpleDialogOption(
                child: const Text("Camera"),
                onPressed: () {
                  camera();
                },
              ),
              SimpleDialogOption(
                child: const Text("Gallery"),
                onPressed: () {
                  gallery();
                },
              ),
              SimpleDialogOption(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  camera() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      file = File(image!.path);
      imageLoaded = true;
    });
  }

  gallery() async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    setState(() {
      file = File(image!.path);
      imageLoaded = true;
    });
  }

  InkWell imagePicker() {
    return InkWell(
      onTap: () async {
        var cameraRequest = await Permission.camera.request();

        var requestResult = cameraRequest.isGranted;
        if (requestResult) {
          selectPhoto();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Give permission to use camera!"),
          ));

          Future.delayed(const Duration(seconds: 3), () {
            openAppSettings();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(75, 25, 75, 25),
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add, size: 100, color: Colors.white),
      ),
    );
  }

  Future<void> uploadImage() async {
    var alert = AlertDialog(
        title: Column(
          children: const [
            CircularProgressIndicator(
              strokeWidth: 2,
            ),
            SizedBox(height: 10),
            Text("Please wait...")
          ],
        ),
        content: const Text("Uploading...", textAlign: TextAlign.center));

    showDialog(context: context, builder: (BuildContext context) => alert);

    String imageURL = await StorageService().uploadImage(widget.userID, file!);
    await FirestoreService().uploadImage(widget.userID, imageURL);
  }

  void alertUser() {
    Widget yesButton = TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          await uploadImage();
          Widget okButton = TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainPage(index: 2)),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("OK"));

          var alert = AlertDialog(
            title: const Text("Complete"),
            content: const Text(
                "You have uploaded your new profile image successfully."),
            actions: [okButton],
          );

          showDialog(
              context: context, builder: (BuildContext context) => alert);
        },
        child: const Text("Yes"));

    Widget noButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text("No"));

    var alertDialog = AlertDialog(
      title: const Text("Confirmation"),
      content: const Text("Upload the image?"),
      actions: [noButton, yesButton],
    );

    showDialog(
        context: context, builder: (BuildContext context) => alertDialog);
  }
}
