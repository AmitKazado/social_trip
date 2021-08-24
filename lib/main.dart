import 'package:flutter/material.dart';
import 'package:social_trip/helper/helper_functions.dart';
import 'package:social_trip/pages/Dashboard.dart';
import 'package:social_trip/pages/authenticate_page.dart';
import 'package:social_trip/pages/home_page.dart';
import 'package:social_trip/pages/Dashboard.dart';
import 'package:social_trip/pages/authenticate_page.dart';

import 'helper/helper_functions.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _getUserLoggedInStatus();
  }

  _getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      if (value != null) {
        setState(() {
          _isLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Chats',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      //home: _isLoggedIn != null ? _isLoggedIn ? HomePage() : AuthenticatePage() : Center(child: CircularProgressIndicator()),
      home: _isLoggedIn ? Dashboard() : AuthenticatePage(),
      //home: HomePage(),
    );
  }
}
