import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_trip/helper/helper_functions.dart';
import 'package:social_trip/models/searchmodel.dart';
import 'package:social_trip/pages/chat_page.dart';
import 'package:social_trip/services/database_service.dart';

import 'home_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // data
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  bool isLoading = false;
  bool hasUserSearched = false;
  bool _isJoined = false;
  String _userName = '';
  User _user;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // initState()
  @override
  void initState() {
    super.initState();
    _getCurrentUserNameAndUid();
  }

  // functions
  _getCurrentUserNameAndUid() async {
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      _userName = value;
    });
    _user = await FirebaseAuth.instance.currentUser;
  }

  SearchModel searchmodel = new SearchModel();
  List<SearchModel> searchlist = new List();
  _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService()
          .searchByName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;

        searchResultSnapshot.docs.forEach((doc) {
          searchmodel = SearchModel.fromMap(doc.data);
          searchlist.add(searchmodel);
          print(searchlist[0].groupName);

          print("im here");
          print(doc);
        });

        //print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Color(0xffa8c66c),
      duration: Duration(milliseconds: 1500),
      content: Text(message,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 17.0)),
    ));
  }

  _joinValueInGroup(
      String userName, String groupId, String groupName, String admin) async {
    bool value = await DatabaseService(uid: _user.uid)
        .isUserJoined(groupId, groupName, userName);
    setState(() {
      _isJoined = value;
    });
  }

  // widgets
  Widget groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                _userName,
                searchlist[index].groupid,
                searchlist[index].groupName,
                searchlist[index].admin,
              );
            })
        : Container();
  }

  bool text = false;
  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    _joinValueInGroup(userName, groupId, groupName, admin);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: Color(0xffa8c66c),
          child: Text(groupName.substring(0, 1).toUpperCase(),
              style: TextStyle(color: Colors.white))),
      title: Text(groupName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(
        "Admin: $admin",
        style: TextStyle(color: Colors.white),
      ),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: _user.uid)
              .togglingGroupJoin(groupId, groupName, userName)
              .then((value) {
            if (value) {
              setState(() {
                text = value;
                print("the value is$text");
              });
            }
          });
          if (_isJoined) {
            setState(() {
              _isJoined = !_isJoined;
            });
            // await DatabaseService(uid: _user.uid).userJoinGroup(groupId, groupName, userName);
            _showScaffold('Successfully joined the group "$groupName"');
            Future.delayed(Duration(milliseconds: 2000), () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomePage()));
            });
          } else {
            setState(() {
              _isJoined = !_isJoined;
            });
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomePage()));

            // _showScaffold('Left the group "$groupName"');
          }
        },
        child: text
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Color(0xff1b6535),
                    border: Border.all(color: Colors.white, width: 1.0)),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text('Pending', style: TextStyle(color: Colors.white)),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xffa8c66c),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text('Join', style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }

  // building the search page widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xff1b6535),
        title: Text('Search',
            style: TextStyle(
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
      body: // isLoading ? Container(
          //   child: Center(
          //     child: CircularProgressIndicator(),
          //   ),
          // )
          // :
          Stack(
        children: [
          Image.asset(
            'assets/background.jfif',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          Container(
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchEditingController,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                              hintText: "Search groups...",
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            _initiateSearch();
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Color(0xffa8c66c),
                                  borderRadius: BorderRadius.circular(40)),
                              child: Icon(Icons.search, color: Colors.white)))
                    ],
                  ),
                ),
                isLoading
                    ? Container(
                        child: Center(child: CircularProgressIndicator()))
                    : groupList()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
