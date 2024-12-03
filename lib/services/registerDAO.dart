import 'package:http/http.dart' as http;

class AccessDataDAO {
  Future<bool> submitData({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('https://golphin-api.onrender.com/auth/register');

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['username'] = name
        ..fields['email'] = email
        ..fields['password'] = password
        ..headers['Content-Type'] = 'application/x-www-form-urlencoded';

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Data submitted successfully');
        return true;
      } else {
        print('Failed to submit data');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
