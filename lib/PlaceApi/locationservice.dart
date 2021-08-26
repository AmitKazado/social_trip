import 'package:flutter/material.dart';
import 'package:social_trip/PlaceApi/placeApiprovider.dart';
import 'package:social_trip/pages/addatrip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import 'dart:convert';
import 'package:flutter/material.dart';

class PlacesAutoComplete extends StatefulWidget {
  PlacesAutoComplete({
    Key key,
    this.title,
    this.tripname,
    this.image,
    this.imgurl,
    this.groupid,
    this.groupname,
    this.username,
  }) : super(key: key);

  final String title;
  final String tripname;
  final dynamic image;
  dynamic groupname, groupid, username,imgurl;
  @override
  _PlacesAutoCompleteState createState() => _PlacesAutoCompleteState();
}

class _PlacesAutoCompleteState extends State<PlacesAutoComplete> {
  final _controller = TextEditingController();
  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  savedata({latlong, place}) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.setString('latlong', latlong);
    await instance.setString('address', place);
    var data = await json.decode(instance.getString('latlong'));
    print("the data is after save is $data");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          'Get Location',
          style: TextStyle(color: Color(0xff1b6535)),
        ),
        centerTitle: true,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Color(0xff1b6535)),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              readOnly: true,
              onTap: () async {
                // generate a new token here
                final sessionToken = Uuid().v4();
                final Suggestion result = await showSearch(
                  context: context,
                  delegate: AddressSearch(sessionToken),
                );

                print(result.description.toString());
                // This will change the text displayed in the TextField
                if (result != null) {
                  final placeDetails = await PlaceApiProvider(sessionToken)
                      .getPlaceDetailFromId(result.placeId);

                  await savedata(
                      latlong: json.encode({
                        'lat': placeDetails['lat'],
                        'lng': placeDetails['lng']
                      }),
                      place: result.description);

                  // latlong.value =
                  //     await json.decode(await datastore.read("latlong"));
                  // print("the lat long is ${latlong.value}");
                  // print(latlong.value['lat']);

                  setState(() {
                    // datastore.write("placename", result.description);
                    // datastore.write("latlong", json.encode(placeDetails));

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddaTrip(
                                  address: result.description.toString(),
                                  tripname: widget.tripname,
                                  image: widget.image,
                                  longlat: placeDetails,
                                  username: widget.username,
                                  groupid: widget.groupid,
                                  groupname: widget.groupname,
                                  imgurl:widget.imgurl,
                                )));
                  });
                }
              },
              decoration: InputDecoration(
                icon: Container(
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                ),
                hintText: "Enter your trip location",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
              ),
            ),
            // SizedBox(height: 20.0),
            // Text('Street Number: $_streetNumber'),
            // Text('Street: $_street'),
            // Text('City: $_city'),
            // Text('Postal Code: $_zipCode'),
          ],
        ),
      ),
    );
  }
}

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title:
                        Text((snapshot.data[index] as Suggestion).description),
                    onTap: () {
                      close(context, snapshot.data[index] as Suggestion);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(child: Text('Loading...')),
    );
  }
}
