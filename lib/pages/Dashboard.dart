import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:social_trip/helper/helper_functions.dart';
import 'package:social_trip/models/pendingrequest.dart';
import 'package:social_trip/pages/map.dart';
import 'package:social_trip/pages/search_page.dart';
import 'package:social_trip/services/database_service.dart';
import 'dart:io';

import 'drawer.dart';
import 'home_page.dart';
import 'notifications.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String usertype = '';
  String _groupdesc = '';
  dynamic _user;
  dynamic _email;
  dynamic _userName;
  // functions
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
    DatabaseService(uid: _user.uid).getUserdetails().then((value) {
      // print(snapshots);
      setState(() {
        usertype = value['usertype'];
        //groupdescription = value['description'];
      });
      usertype == "Manager" ? getproper() : print("im traveler");
    });
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  localnotifications() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Notifications(
                    groupId: data.docs[0].data()['groupid'],
                    groupName: data.docs[0].data()['groupname'],
                    userName: data.docs[0].data()['username'],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Notifications(),
      ),
    );
  }

  var data;
  dynamic data2;
  List<dynamic> tripid = [0];
  List<PendingModel> pendinglist = new List();

  PendingModel pendingmodel = new PendingModel();
  getrequests() async {
    data =
        await FirebaseFirestore.instance.collection('pending requests').get();
    //  print(data.docs[0]['groupid']);
    data.docs.forEach((doc) {
      pendingmodel = PendingModel.fromMap(doc.data());
      pendinglist.add(pendingmodel);

      print("im here${pendinglist.length}");
      print(doc);
    });
    if (data.docs.length != 0 && data.docs != null) {
      for (int i = 0; i < data.docs.length; i++) {
        if (tripid[i] == data.docs[i].data()['tripid']) {
          print("same trip id");
        } else {
          setState(() {
            if (tripid.contains(data.docs[i].data()['tripid'])) {
              //_showNotification();
              print("already exist");
            } else {
              _showNotification();
              tripid.add(data.docs[i].data()['tripid']);
            }
          });
        }
      }
    }
  }

  Timer timer;

  getproper() {
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => getrequests());
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            '1', 'New Request', 'Someone wants to join trip',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'New Request',
        'Someone wants to join trip', platformChannelSpecifics,
        payload: 'item x');
  }

  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
    localnotifications();
  }

  @override
  void dispose() {
    timer == null ? null : timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',
            style: TextStyle(
                color: Colors.white,
                fontSize: 27.0,
                fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xff1b6535),
        elevation: 0.0,
        centerTitle: true,
      ),
      drawer: CustomDrawer(
        email: _email,
        username: _userName,
      ),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
          children: [
            Image.asset(
              'assets/background.jfif',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
            Positioned(
                top: 150,
                left: 30,
                right: 30,
                child: Column(
                  children: [
                    Text('Hello $_userName',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 27.0,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => HomePage()));
                          },
                          child: Container(
                            // color: Color(0xff1b6535),
                            height: 150,
                            width: 150,
                            child: Card(
                              elevation: 5.0,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/grouppng.png',
                                    width: 50,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Groups',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Maps()));
                          },
                          child: Container(
                            // color: Color(0xff1b6535),
                            height: 150,
                            width: 150,
                            child: Card(
                              elevation: 5.0,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/map.png',
                                    width: 50,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Map',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = FlatButton(
      child: Text("Yes"),
      onPressed: () async {
        exit(0);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Are you Sure?"),
      content: Text('You want to exit app'),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
