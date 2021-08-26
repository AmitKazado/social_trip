import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_trip/controllers/PlaceApi/locationservice.dart';
import 'package:social_trip/controllers/helper/helper_functions.dart';
import 'package:social_trip/pages/home_page.dart';
import 'package:social_trip/pages/trippage.dart';
import 'package:social_trip/controllers/services/auth_service.dart';
import 'package:social_trip/controllers/services/database_service.dart';
import 'package:social_trip/controllers/shared/constants.dart';
import 'package:social_trip/controllers/shared/loading.dart';
import 'package:image_picker/image_picker.dart';

class AddaTrip extends StatefulWidget {
  final Function toggleView;
  dynamic groupname,
      groupid,
      username,
      address,
      longlat,
      tripname,
      image,
      imgurl;
  AddaTrip(
      {this.toggleView,
      this.groupid,
      this.groupname,
      this.username,
      this.address,
      this.tripname,
      this.imgurl,
      this.image,
      this.longlat});

  @override
  _AddaTripState createState() => _AddaTripState();
}

class _AddaTripState extends State<AddaTrip> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String tripname = '';
  String triplocation = '';

  File _pickedImage;
  final ImagePicker _picker = ImagePicker();

  TextEditingController address;
  TextEditingController date;
  TextEditingController ctripname;

  Future _pickImage() async {
    final pickedImageFile =await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );


    setState(() {
      _pickedImage = File(pickedImageFile.path);
      uploadimage(_pickedImage);
    });
  }

  dynamic picurl;

  bool picloading = false;
  uploadimage(image) async {
    setState(() {
      picloading = true;
    });

    final ref = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(DateTime.now().toString() + ".jpg");
    await ref.putFile(image);

    final url = await ref.getDownloadURL();

    setState(() {
      picurl = url;
      print(picurl);
      picloading = false;
    });
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        date = new TextEditingController(
            text: "${selectedDate.toLocal()}".split(' ')[0]);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    address = new TextEditingController(text: widget.address);

    tripname = widget.tripname;
    _pickedImage = widget.image;
    ctripname = new TextEditingController(text: widget.tripname);
    picurl = widget.imgurl;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.groupid);
    return Scaffold(
        body: Form(
      key: _formKey,
      child: Container(
        color: Color(0xff1b6535),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Add a Trip",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold)),
                  ],
                )),

                SizedBox(height: 30.0),

                FittedBox(
                  child: Container(
                    color: Color(0xffa8c66c),
                    width: 150,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(0.0),
                      child: _pickedImage != null
                          ? Image(
                              fit: BoxFit.fill,
                              alignment: Alignment.topRight,
                              image: FileImage(_pickedImage))
                          : Container(),
                    ),
                  ),
                ),
//
                picloading
                    ? Center(child: CircularProgressIndicator())
                    : FlatButton.icon(
                        textColor: Color(0xffa8c66c),
                        onPressed: _pickImage,
                        icon: Icon(Icons.image),
                        label: Text("Add Image"),
                      ),
                SizedBox(height: 20.0),

                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration:
                      textInputDecoration.copyWith(labelText: 'Name of Trip'),
                  validator: (val) {
                    return val.length != 0 ? null : "name cannot be empty";
                  },
                  controller: ctripname,
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  controller: address,
                  readOnly: true,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlacesAutoComplete(
                                  image: _pickedImage,
                                  tripname: ctripname.text,
                                  username: widget.username,
                                  groupname: widget.groupname,
                                  groupid: widget.groupid,
                                  imgurl: picurl,
                                )));
                  },
                  style: TextStyle(color: Colors.white),
                  decoration:
                      textInputDecoration.copyWith(labelText: 'Location'),
                  validator: (val) =>
                      val.length == 0 ? 'location cannot be empty' : null,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: date,
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  style: TextStyle(color: Colors.white),
                  decoration: textInputDecoration.copyWith(
                      labelText: 'Select the date of trip'),
                ),
                SizedBox(height: 15.0),

                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: RaisedButton(
                            elevation: 0.0,
                            color: Color(0xffa8c66c),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Text('Add Trip',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0)),
                            onPressed: () async {
                              if (widget.username == null ||
                                  widget.groupname == null ||
                                  ctripname.text.isEmpty ||

                                  address.text.isEmpty ||
                                  widget.groupid == null) {
                                Fluttertoast.showToast(
                                    msg:
                                        'You have to fill all the fields first');
                              } else {
                                setState(() {
                                  _isLoading = true;
                                });
                                dynamic _user =
                                    await FirebaseAuth.instance.currentUser;

                                await DatabaseService(uid: _user.uid)
                                    .createTrips(
                                        userName: widget.username,
                                        groupName: widget.groupname,
                                        tripname: ctripname.text,
                                        image: picurl.toString(),
                                        triplocation: address.text,
                                        tripdate: date.text,
                                        groupId: widget.groupid);
                                //  _onSignIn();
                                setState(() {
                                  _isLoading = false;
                                });

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TripPage(
                                              groupId: widget.groupid,
                                              groupName: widget.groupname,
                                              userName: widget.username,
                                            )));
                              }
                            }),
                      ),
                SizedBox(height: 10.0),

                SizedBox(height: 10.0),
                // Text(error,
                //     style: TextStyle(color: Colors.red, fontSize: 14.0)),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
