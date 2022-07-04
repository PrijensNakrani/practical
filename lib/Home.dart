import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:practical/Services/Api_service.dart';

import 'Services/model.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List name = ["Dental", "Cardiologist", "Eye Special", "Skin Specialist"];
  List image = [
    "assets/dental.png",
    "assets/cardiologist.png",
    "assets/eye.png",
    "assets/skin.png"
  ];
  @override
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
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: height * 0.2,
                    width: width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xff4DC6FD), Color(0xff00CCCB)]),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Find Your Doctor",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: -height * 0.03,
                    right: width * 0.09,
                    child: Container(
                      height: height * 0.06,
                      width: width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                      child: ListTile(
                          title: Text("Search"),
                          leading: Icon(Icons.search),
                          trailing: Icon(Icons.close)),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: height * 0.05,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...List.generate(
                      image.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Column(
                          children: [
                            Container(
                              height: height * 0.1,
                              width: width * 0.22,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: AssetImage("${image[index]}"),
                                      fit: BoxFit.cover)),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Text(
                              "${name[index]}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Popular Doctor",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              FutureBuilder(
                future: ApiServices.getData(),
                builder:
                    (BuildContext context, AsyncSnapshot<DoctorData> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: GridView.builder(
                          itemCount: snapshot.data?.users?.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 15,
                                  crossAxisSpacing: 10,
                                  mainAxisExtent: 280),
                          itemBuilder: (BuildContext context, int index) {
                            var info = snapshot.data?.users![index];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        height: height * 0.2,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                        ),
                                        child: info!.avatar != null ||
                                                info.avatar!.isNotEmpty ||
                                                info.avatar != ""
                                            ? Image.network("${info.avatar}",
                                                fit: BoxFit.cover)
                                            : Image.asset("assets/profile.jpg"),
                                      ),
                                      Positioned(
                                          top: height * 0.02,
                                          right: width * 0.02,
                                          child: Icon(Icons.favorite_border))
                                    ],
                                  ),
                                  Text(
                                    "${info.firstName}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${info.username}",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.grey),
                                  ),
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (index) => Icon(
                                          Icons.star,
                                          color: Color(0xffF6D060),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
