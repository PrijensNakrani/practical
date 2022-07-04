import 'dart:convert';

import 'package:http/http.dart' as http;

import 'model.dart';

class ApiServices {
  static Future<DoctorData> getData() async {
    http.Response response = await http.get(Uri.parse(
        "https://codelineinfotech.com/student_api/User/allusers.php"));
    print("${jsonDecode(response.body)}");
    return doctorDataFromJson(response.body);
  }
}
