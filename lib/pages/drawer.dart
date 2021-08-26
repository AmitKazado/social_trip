import 'package:flutter/material.dart';
import 'package:social_trip/pages/Dashboard.dart';

import '../controllers/services/auth_service.dart';
import 'authenticate_page.dart';
import 'map.dart';
import 'profile_page.dart';

class CustomDrawer extends StatefulWidget {
  String username, email;

  CustomDrawer({this.username, this.email});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        children: <Widget>[
          Icon(Icons.account_circle, size: 150.0, color: Colors.grey[700]),
          SizedBox(height: 15.0),
          Text(widget.username,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 7.0),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Dashboard()));
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.account_circle),
            title: Text('Dashboard'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ProfilePage(
                      userName: widget.username, email: widget.email)));
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          ListTile(
            onTap: () async {
              await _auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthenticatePage()),
                  (Route<dynamic> route) => false);
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
