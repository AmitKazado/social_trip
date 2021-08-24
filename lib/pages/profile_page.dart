import 'package:flutter/material.dart';
import 'package:social_trip/pages/authenticate_page.dart';
import 'package:social_trip/pages/drawer.dart';
import 'package:social_trip/pages/home_page.dart';
import 'package:social_trip/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String email;
  final AuthService _auth = AuthService();

  ProfilePage({this.userName, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 27.0,
                fontWeight: FontWeight.bold)),
        backgroundColor:Color(0xff1b6535), 
        elevation: 0.0,
      ),
      drawer: CustomDrawer(
        username: userName,
        email: email,
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 130.0),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.account_circle,
                    size: 200.0, color: Colors.grey[700]),
                SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Full Name', style: TextStyle(fontSize: 17.0)),
                    Text(userName, style: TextStyle(fontSize: 17.0)),
                  ],
                ),
                Divider(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Email', style: TextStyle(fontSize: 17.0)),
                    Text(email, style: TextStyle(fontSize: 17.0)),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
