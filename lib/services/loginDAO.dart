import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginDAO {
  Future<bool> submitData({
    required String credential,
    required String password,
  }) async {
    final url = Uri.parse('https://golphin-api.onrender.com/auth/login');

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['auth'] = credential
        ..fields['password'] = password
        ..headers['Content-Type'] = 'application/x-www-form-urlencoded'; 

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody); 
        final token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLogged', true);
        await prefs.setString('JWT', token);

        print('Login successful, data stored');
        return true;
      } else {
        print('Failed to log in');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
