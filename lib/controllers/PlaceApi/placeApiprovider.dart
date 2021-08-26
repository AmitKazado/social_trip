import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class Place {
  String streetNumber;
  String street;
  String city;
  String zipCode;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static final String androidKey = 'AIzaSyD2rfGv18W64BbFkepC5zR7dqIOIIlBPBY';
  static final String iosKey = 'AIzaSyD2rfGv18W64BbFkepC5zR7dqIOIIlBPBY';
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      print("the resutls are $result");
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<dynamic> getPlaceDetailFromId(String placeId) async {
    try {
      final request =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry/location&key=$apiKey&sessiontoken=$sessionToken';
      final response = await client.get(Uri.parse(request));

      print(request);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print(result['result']['geometry']['location']);
        if (result['status'] == 'OK') {
          final components = result['result']['geometry']['location'];
          print("the logn and lat is $components");

          return components;
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
