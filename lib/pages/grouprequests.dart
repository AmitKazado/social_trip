import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_trip/helper/helper_functions.dart';
import 'package:social_trip/models/grouprequests.dart';
import 'package:social_trip/models/tripdetails.dart';
import 'package:social_trip/pages/chat_page.dart';
import 'package:social_trip/services/auth_service.dart';
import 'package:social_trip/services/database_service.dart';
import 'package:social_trip/widgets/group_tile.dart';

import 'addatrip.dart';

class Grouprequests extends StatefulWidget {
  final String groupId;
  final String userName;
  final String groupName;

  Grouprequests({this.groupId, this.userName, this.groupName});
  @override
  _GrouprequestsState createState() => _GrouprequestsState();
}

class _GrouprequestsState extends State<Grouprequests> {
  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _userName = '';
  String _email = '';
  Stream trips;
  Stream pendingrequests;

  dynamic usertype;
  Stream travelertrips;
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });

    DatabaseService(uid: _user.uid).getUserdetails().then((value) {
      // print(snapshots);
      setState(() {
        usertype = value['usertype'];
      });
    });

    await DatabaseService(uid: _user.uid)
        .getpendingGroupsrequests(widget.groupId)
        .then((snapshots) {
      // print(snapshots);
      setState(() {
        pendingrequests = snapshots;
      });
    });
    DatabaseService().gettrips2(widget.groupId).then((snapshots) {
      // print(snapshots);
      setState(() {
        travelertrips = snapshots;
      });
    });
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
    //   tripList();
  }

  List listoftrips = ['Hunza', 'Chitrla', 'Skardu'];
  @override
  Widget build(BuildContext context) {
    print("the user dtype is $usertype");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1b6535),
        title: Text("Notifications"),
        centerTitle: true,
        actions: [
          IconButton(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              icon: Icon(Icons.notifications, color: Colors.white, size: 25.0),
              onPressed: () {
                // Navigator.of(context).push(
                //     MaterialPageRoute(builder: (context) => SearchPage()));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Container(
                  //    height: 100,
                  width: MediaQuery.of(context).size.width - 30,
                  child: Card(
                      elevation: 3.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "New Requests",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            //  travelertripList(),
                            usertype == "Manager"
                                ? travelertripList()
                                : travelertripList(),
                          ],
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // String _destructureName(String res) {
  //   // print(res.substring(res.indexOf('_') + 1));
  //   return res.substring(res.indexOf('_') + 1);
  // }

  List<GroupPendingModel> grouplist = new List();

  GroupPendingModel groupmodel = new GroupPendingModel();
  List<bool> isjoinedtrip = [
    false,
    false,
    false,
    false,
    false,
  ];
  bool isLoading = false;
  Widget travelertripList() {
    print(widget.userName);
    return StreamBuilder(
      stream: pendingrequests,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents != null) {
            // print(snapshot.data['groups'].length);
            if (snapshot.data.documents.length != 0) {
              return ListView.builder(
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    snapshot.data.documents.forEach((doc) {
                      groupmodel = GroupPendingModel.fromMap(doc.data);
                      grouplist.add(groupmodel);

                      print("im here");
                      print(doc);
                    });
                    // int reqIndex = snapshot.data.documents.length - index - 1;
                    return ListTile(
                      onTap: () {},
                      title: Text(grouplist[index].username),
                      subtitle: Text(grouplist[index].groupname),
                      trailing: Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              await DatabaseService(
                                      uid: grouplist[index].userid)
                                  .acceptingGroupRequest(
                                      grouplist[index].groupid,
                                      grouplist[index].groupname,
                                      grouplist[index].username);
                              await DatabaseService(
                                      uid: grouplist[index].userid)
                                  .deletegrouprequests(grouplist[index].groupid,
                                      grouplist[index].groupname, "");
                              // await DatabaseService(uid: grouplist[index].userid)
                              //     .togglingTripJoin(
                              //   triplist[index].tripid,
                              //   triplist[index].groupid,
                              //   triplist[index].tripname,
                              //   triplist[index].username,
                              // );
                              // await DatabaseService(
                              //         uid: snapshot.data.documents[index]
                              //             ['userid'])
                              //     .deleterequests(
                              //         triplist[index].tripid,
                              //         triplist[index].groupid,
                              //         triplist[index].tripname,
                              //         triplist[index].username,
                              //         index,
                              //         true,
                              //         "accept");
                              if (isjoinedtrip[index]) {
                                setState(() {
                                  isjoinedtrip[index] = !isjoinedtrip[index];
                                });
                              } else {
                                setState(() {
                                  isjoinedtrip[index] = true;
                                });
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(0xffa8c66c),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5.0),
                              child: Text(isLoading ? 'Please wait ' : 'Accept',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                                await DatabaseService(
                                      uid: grouplist[index].userid)
                                  .deletegrouprequests(grouplist[index].groupid,
                                      grouplist[index].groupname, "");
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.red,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5.0),
                              child: Text(
                                  isLoading ? 'Please wait ' : 'Decline',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            } else {
              return Container(
                child: Text('No Request available'),
              );
            }
          } else {
            return Container(
              child: Text('No Request available'),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
