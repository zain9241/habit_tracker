import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchCountries() async {
  final response = await http
      .get(Uri.parse('https://date.nager.at/api/v3/AvailableCountries'));

  if (response.statusCode == 200) {
    List<dynamic> countriesJson = json.decode(response.body);
    List<String> countryList =
    countriesJson.map((country) => country['name'] as String).toList();
    countryList.sort();
    return countryList;
  } else {
    throw Exception('Failed to load countries');
  }
}