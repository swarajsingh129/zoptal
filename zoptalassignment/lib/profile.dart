import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zoptalassignment/constant.dart';
import 'package:path/path.dart' as j;

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late File file;
  bool loading = true;
  String name = "";
  String birth = "";
  String gen = "";
  String url = "";
  final ImagePicker picker = ImagePicker();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  getdata() async {
    setState(() {
      loading = true;
    });
    await FirebaseFirestore.instance
        .collection("test")
        .doc("xyz")
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          name = value.data()!["name"];
          gen = value.data()!["gen"];
          birth = value.data()!["birth"];
          url = value.data()!["url"];
        });
      }
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      InkWell(
                        onTap: () async {
                          await selectPhoto(context);
                        },
                        child: url == ""
                            ? const CircleAvatar(
                                backgroundImage: AssetImage("assets/pro.jpg"),
                                radius: 50,
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(url),
                                radius: 50,
                              ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      RTextfield(
                        title: "Name",
                        onChanged: (v) {
                          name = v;
                        },
                        icon: Icons.person,
                        data: name,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RTextfield(
                        title: "Birth Date",
                        onChanged: (v) {
                          birth = v;
                        },
                        icon: Icons.calendar_month,
                        data: birth,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      RTextfield(
                        title: "Gender",
                        onChanged: (v) {
                          gen = v;
                        },
                        icon: Icons.male,
                        data: gen,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("test")
                                  .doc("xyz")
                                  .update({
                                "name": name,
                                "birth": birth,
                                "gen": gen,
                                "url": url,
                              });
                              await getdata();
                            },
                            child: const Text("Profile Edit Screen")),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future selectPhoto(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text("Camera"),
                      onTap: () async {
                        Navigator.pop(context);

                        getImage(
                          ImageSource.camera,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.album),
                      title: const Text("Gallery"),
                      onTap: () async {
                        Navigator.pop(context);
                        getImage(
                          ImageSource.gallery,
                        );
                      },
                    )
                  ],
                );
              });
        });
  }

  Future getImage(ImageSource source) async {
    final imageFile = await picker.pickImage(source: source, imageQuality: 60);
    if (imageFile == null) {
      return;
    }
    var file = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));

    if (file == null) {
      return;
    }

    file = await compressImage(file.path, 60);

    return await uploadImage(file!.path);
  }

  Future compressImage(String path, int quality) async {
    final newpath = j.join((await getTemporaryDirectory()).path,
        "${DateTime.now()}.${j.extension(path)}");
    final result = await FlutterImageCompress.compressAndGetFile(path, newpath,
        quality: quality);
    return result;
  }

  Future uploadImage(String path) async {
    final ref =FirebaseStorage.instance
        .ref()
        .child("gallery")
        .child("${DateTime.now().toIso8601String()}.$path");
    final result = await ref.putFile(File(path));

    url = await result.ref.getDownloadURL();

    setState(() {});
  }
}
