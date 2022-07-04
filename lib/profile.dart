import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practical/Bottom.dart';
import 'package:practical/Services/Firebase%20Services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Services/const.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  final picker = ImagePicker();
  File? _imageGallery;
  File? _imageCamera;
  var selectedHobbies = 0;
  var selectedGender = 0;
  var selectedValue = "India";
  var visibility = true;
  List<String> cities = ["US", "China", "New Zealand", "Australia", "India"];
  List gender = ["Male", "Female"];
  List hobbies = ["singing", "Dancing"];
  final formKey = GlobalKey<FormState>();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final password = TextEditingController();
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

  Future addUserData() async {
    String? userImage = await uploadFile(
        file: _imageGallery != null ? _imageGallery : _imageCamera,
        filename: "${kFirebaseAuth.currentUser!.email}");
    FirebaseFirestore.instance
        .collection('users')
        .doc(kFirebaseAuth.currentUser!.uid)
        .set({
      "email": email.text,
      "firstname": firstName.text,
      "lastname": lastName.text,
      "mobile": mobile.text,
      "countries": selectedValue,
      "gender": selectedGender == 0 ? "Male" : "Female",
      "hobbies": selectedHobbies == 0 ? "singing" : "Dancing",
      "userImage": userImage,
    }).catchError(
      (e) {
        print("ERROR==<<$e");
      },
    );
  }

  Widget build(BuildContext context) {
    var height = Get.height;
    var width = Get.width;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xff61CEFFBD),
                Color(0xffFFFFFF),
                Color(0xffFFFFFF),
                Color(0xffFFFFFF),
                Color(0xff61CEFFBD)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: height * 0.2,
                        width: height * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: _imageGallery == null
                            ? Image.asset("assets/profile1.png",
                                fit: BoxFit.fill)
                            : _imageCamera == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      _imageGallery!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(_imageCamera!,
                                        fit: BoxFit.cover),
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
                                        getCameraImage();
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Container(
                                          height: height * 0.063,
                                          width: width,
                                          decoration: BoxDecoration(
                                              color: Color(0xff4DC6FD),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
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
                                        getGalleryImage();
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Container(
                                          height: height * 0.063,
                                          width: width,
                                          decoration: BoxDecoration(
                                              color: Color(0xff4DC6FD),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
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
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Text(
                    "Set up your Profile",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Text(
                    "Update your profile to connect your doctor with \nbetter impression.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: height * 0.06,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Registration",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
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
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
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
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
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
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey)),
                          child: TextFormField(
                            controller: email,
                            validator: (value) {
                              RegExp regex = RegExp(
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                              if (!regex.hasMatch(value!)) {
                                return "Enter valid Email";
                              }
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 25),
                              hintText: "Email",
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
                          height: height * 0.02,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey)),
                          child: TextFormField(
                            controller: mobile,
                            maxLength: 10,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter Mobile Number";
                              } else if (value.length < 10) {
                                return "Enter a valid 10 Mobile Number";
                              }
                            },
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              counter: Offstage(),
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
                                  width: width * 0.01,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 5.0),
                                              child: Container(
                                                height: height * 0.02,
                                                width: height * 0.02,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    shape: BoxShape.circle),
                                                child: Column(
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                          height: height * 0.02,
                                                          width: width * 0.02,
                                                          decoration: BoxDecoration(
                                                              color: selectedGender ==
                                                                      index
                                                                  ? Colors.white
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
                            padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                    icon: const Icon(Icons.keyboard_arrow_down),
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
                          height: height * 0.03,
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: width * 0.01,
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
                                  width: width * 0.005,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                        : Colors.transparent,
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
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey)),
                          child: TextFormField(
                            controller: password,
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              RegExp regex = RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                              if (!regex.hasMatch(value!)) {
                                return "Enter valid password";
                              }
                            },
                            obscureText: visibility,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15),
                              hintText: "Password",
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        visibility = !visibility;
                                      },
                                    );
                                  },
                                  icon: visibility
                                      ? Icon(Icons.visibility)
                                      : Icon(Icons.visibility_off)),
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
                        GestureDetector(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              bool status = await FirebaseServices.signUp(
                                  password: password.text, email: email.text);
                              SharedPreferences _prefs =
                                  await SharedPreferences.getInstance();
                              _prefs.setString("email", email.text);
                              if (status == true) {
                                await addUserData();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        content: Text("Successfully SignUp")))
                                    .closed
                                    .whenComplete(() => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Bottom(),
                                          ),
                                        ));
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              height: height * 0.06,
                              width: width,
                              decoration: BoxDecoration(
                                  color: Color(0xff4DC6FD),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                child: Text(
                                  "Submit",
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
        ),
      ),
    );
  }
}
