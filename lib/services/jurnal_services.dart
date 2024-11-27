import 'dart:convert';
import 'package:http/http.dart' as http;

class JournalService {
  final String apiKey =
      '3tOdWMluuR3e0IeIAl9a3g==Kj258dQSdMbApb3l'; // Replace with your API key from API Ninjas

  Future<List<String>> fetchJournalingIdeas() async {
    final url = Uri.parse('https://api.api-ninjas.com/v1/quotes');
    final headers = {
      'X-Api-Key': apiKey, // Add your API key in the header
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract quotes from the API response
        return List<String>.from(data.map((quote) => quote['quote']));
      } else {
        print('Error Response: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to fetch journaling ideas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch journaling ideas: $e');
    }
  }
}
