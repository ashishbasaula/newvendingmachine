import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkServices {
  // GET request
  Future<String> get(
      {required String endpoint, Map<String, String>? header}) async {
    try {
      final url = Uri.parse(endpoint);
      final response = await http.get(
        url,
        headers: header,
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
      {required String endpoint, required Map<String, dynamic> body}) async {
    try {
      final url = Uri.parse(endpoint);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
