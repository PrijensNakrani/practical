import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practical/Services/Firebase%20Services.dart';
import 'package:practical/Services/const.dart';
import 'package:practical/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Update extends StatefulWidget {
  const Update({Key? key}) : super(key: key);

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final password = TextEditingController();

  List<String> cities = ["US", "China", "New Zealand", "Australia", "India"];
  List gender = ["Male", "Female"];
  List hobbies = ["singing", "Dancing"];
  File? _imageGallery;
  String? img;
  File? _imageCamera;
  var selectedHobbies = 0;
  var selectedGender = 0;
  var selectedValue = "India";
  var visibility = true;
  Future getCameraImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(
        () {
          _imageCamera = File(pickedFile.path);
        },
      );
    }
  }

  Future getGalleryImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(
        () {
          _imageGallery = File(pickedFile.path);
        },
      );
    }
  }

  Future<String?> uploadFile({File? file, String? filename}) async {
    print("File path:$file");

    try {
      var response = await FirebaseStorage.instance
          .ref("user_image/$filename")
          .putFile(file!);
      var result =
          await response.storage.ref("user_image/$filename").getDownloadURL();
      return result;
    } on firebase_storage.FirebaseException catch (e) {
      print("ERROR===>>$e");
    }
    return null;
  }

  void getUserData() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic>? getUserData = user.data() as Map<String, dynamic>?;
    firstName.text = getUserData!['firstname'];
    lastName.text = getUserData['lastname'];
    mobile.text = getUserData["mobile"];
    setState(() {
      img = getUserData['userImage'];
    });
    mobile.text = getUserData['mobile'];
    selectedValue = getUserData['countries'];
  }

  @override
  void initState() {
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        height: height * 0.38,
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15)),
                          gradient: LinearGradient(
                            colors: [Color(0xff4DC6FD), Color(0xff00CCCB)],
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      height: height * 0.06,
                                      width: height * 0.06,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                          child: Icon(
                                        Icons.arrow_back_ios,
                                        size: 14,
                                      )),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width * 0.1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0),
                                    child: Text(
                                      "Profile",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      SharedPreferences _prefs =
                                          await SharedPreferences.getInstance();
                                      _prefs.remove("email");
                                      FirebaseServices.logOut();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Profile(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      child: Text(
                                        "Logout",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: height * 0.2,
                                  width: height * 0.2,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: _imageGallery == null
                                        ? img != null
                                            ? Image.network("$img",
                                                fit: BoxFit.fill)
                                            : Center(
                                                child:
                                                    CircularProgressIndicator())
                                        : _imageCamera == null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.file(
                                                  _imageGallery!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.file(_imageCamera!,
                                                    fit: BoxFit.cover),
                                              ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -height * 0.01,
                                  right: -width * 0.02,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            actions: [
                                              SizedBox(
                                                height: height * 0.02,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    getCameraImage();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  child: Container(
                                                    height: height * 0.063,
                                                    width: width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xff4DC6FD),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Center(
                                                      child: Text(
                                                        "Camera",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: height * 0.02,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    getGalleryImage();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0),
                                                  child: Container(
                                                    height: height * 0.063,
                                                    width: width,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xff4DC6FD),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Center(
                                                      child: Text(
                                                        "Gallery",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: height * 0.02,
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Image.asset(
                                      "assets/camera.png",
                                      fit: BoxFit.cover,
                                      height: height * 0.07,
                                      width: height * 0.07,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: width * 0.4,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey)),
                                  child: TextFormField(
                                    controller: firstName,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter a FirstName";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 25),
                                      hintText: "First Name",
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: width * 0.4,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey)),
                                  child: TextFormField(
                                    controller: lastName,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter a LastName";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 25),
                                      hintText: "Last Name",
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Container(
                              height: height * 0.065,
                              width: width,
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey)),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "${kFirebaseAuth.currentUser!.email}",
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey)),
                              child: TextFormField(
                                controller: mobile,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter Mobile Number";
                                  } else if (value.length < 10) {
                                    return "Enter a valid Mobile Number";
                                  }
                                },
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 25),
                                  hintText: "Mobile Number",
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.03,
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: width * 0.05,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Text(
                                        "Gender",
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.grey),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.03,
                                    ),
                                    Row(
                                      children: [
                                        ...List.generate(
                                          2,
                                          (index) => InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  selectedGender = index;
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 5,
                                                      horizontal: 5.0),
                                                  child: Container(
                                                    height: height * 0.02,
                                                    width: height * 0.02,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        shape: BoxShape.circle),
                                                    child: Column(
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                              height:
                                                                  height * 0.02,
                                                              width:
                                                                  width * 0.02,
                                                              decoration: BoxDecoration(
                                                                  color: selectedGender ==
                                                                          index
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .transparent,
                                                                  shape: BoxShape
                                                                      .circle)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${gender[index]}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.grey),
                                                ),
                                                SizedBox(
                                                  width: width * 0.08,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: height * 0.03,
                            ),
                            Container(
                              height: height * 0.06,
                              width: width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: height * 0.06,
                                      width: width * 0.8,
                                      child: DropdownButton(
                                        underline: Container(),
                                        value: selectedValue,
                                        hint: Text("Country"),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Color(0xff677294),
                                        ),
                                        isExpanded: true,
                                        iconSize: 32,
                                        icon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        items: cities.map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedValue = newValue!;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: width * 0.05,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Text(
                                        "Hobbies",
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.grey),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width * 0.01,
                                    ),
                                    Row(
                                      children: [
                                        ...List.generate(
                                          2,
                                          (index) => InkWell(
                                            onTap: () {
                                              setState(
                                                () {
                                                  selectedHobbies = index;
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 5,
                                                      horizontal: 5.0),
                                                  child: Container(
                                                    height: height * 0.02,
                                                    width: height * 0.02,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        size: 15,
                                                        color: selectedHobbies ==
                                                                index
                                                            ? Colors.white
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "${hobbies[index]}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.grey),
                                                ),
                                                SizedBox(
                                                  width: width * 0.05,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  String? userImage = await uploadFile(
                                      file: _imageGallery != null
                                          ? _imageGallery
                                          : _imageCamera,
                                      filename:
                                          "${kFirebaseAuth.currentUser!.email}");

                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(kFirebaseAuth.currentUser!.uid)
                                      .update(
                                    {
                                      "firstname": firstName.text,
                                      "lastname": lastName.text,
                                      "mobile": mobile.text,
                                      "userImage": userImage,
                                      "countries": selectedValue,
                                      "gender": selectedGender == 0
                                          ? "Male"
                                          : "Female",
                                      "hobbies": selectedHobbies == 0
                                          ? "singing"
                                          : "Dancing",
                                    },
                                  ).then(
                                    (value) => ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text("Successfully Update"),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  height: height * 0.06,
                                  width: width,
                                  decoration: BoxDecoration(
                                      color: Color(0xff4DC6FD),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Center(
                                    child: Text(
                                      "Update",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.1,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
