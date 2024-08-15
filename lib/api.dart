import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> sendQuestionToApi(String question) async {
  final url = Uri.parse('http://localhost:8000/ask/');
  print('API request URL: $url');
  print('Sending question: $question');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'question': question}),
  );

  print('API response status code: ${response.statusCode}');
  print('API response body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    print('API response decoded: $jsonResponse');
    List<String> sources = List<String>.from(jsonResponse['source_documents']);
    return {
      'result': jsonResponse['result'],
      'source_documents': sources,
    };
  } else {
    return {
      'result': 'Error: Unable to get response from the API',
      'source_documents': [],
    };
  }
}
