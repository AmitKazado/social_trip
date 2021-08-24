import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  // Collection reference
  final CollectionReference userCollection =
    FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
    FirebaseFirestore.instance.collection('groups');

  final CollectionReference tripsCollection =
    FirebaseFirestore.instance.collection('groups');
  // update userdata
  Future updateUserData(
      String fullName, String email, String password, String usertype) async {
    return await userCollection.document(uid).setData({
      'fullName': fullName,
      'email': email,
      'password': password,
      'usertype': usertype,
      'groups': [],
      'trips': [],
      'profilePic': ''
    });
  }

  // create group
  Future createGroup(String userName, String groupName, description) async {
    DocumentReference groupDocRef = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': userName,
      'members': [],
      //'messages': ,
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': '',
      'groupdescription': description
    });

    await groupDocRef.updateData({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      'groupId': groupDocRef.documentID
    });

    DocumentReference userDocRef = userCollection.document(uid);
    return await userDocRef.updateData({
      'groups':
          FieldValue.arrayUnion([groupDocRef.documentID + '_' + groupName])
    });
  }

  //create trips
  Future createTrips(
      {String userName,
      String groupName,
      String tripname,
      String image,
      String tripdate,
      String groupId,
      String triplocation}) async {
    DocumentReference tripDocRef =
        await tripsCollection.document(groupId).collection("trips").add({
      'groupName': groupName,
      'tripname': '$tripname',
      'admin': userName,
      'location': triplocation,
      'image': image,
      "tripdate": tripdate,

      'members': [],
      "date": DateTime.now().toLocal().toString().split(" ")[0],
      //'messages': ,
      'tripId': '',
      'recentMessage': '',
      'recentMessageSender': ''
    });

    await tripDocRef.updateData({
      'members': FieldValue.arrayUnion([uid + '_' + userName]),
      'tripId': tripDocRef.documentID
    });

    DocumentReference userDocRef = userCollection.document(uid);
    return await userDocRef.updateData({
      'trips': FieldValue.arrayUnion([tripDocRef.documentID + '_' + tripname])
    });
  }

  // toggling the user group join
  Future togglingGroupJoin(
    String groupId,
    String groupName,
    String userName,
  ) async {
    bool istrue = false;
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupCollection.document(groupId);

    List<dynamic> groups = await userDocSnapshot.data['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      istrue = true;
      //print('hey');
      await userDocRef.updateData({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
      });

      await groupDocRef.updateData({
        'members': FieldValue.arrayRemove([uid + '_' + userName])
      });
      return false;
    } else {
      print("updating");
      if (istrue) {
        var jobskill_query = await Firestore.instance
            .collection('grouprequests')
            .where('userid', isEqualTo: uid)
            .getDocuments();

        jobskill_query.documents.forEach((element) {
          element.reference.delete();
        });
        Fluttertoast.showToast(msg: "Your request has been removed");
        return false;
      } else {
        await FirebaseFirestore.instance.collection('grouprequests').add({
          "status": "pending",
          "groupid": groupId,
          "userid": uid,
          "username": userName,
          "groupname": groupName,
        });

        Fluttertoast.showToast(
            msg: "Please wait for admin to approve your request");
        return true;
      }
      //print('nay');

      // await userDocRef.updateData({
      //   'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
      // });

      // await groupDocRef.updateData({
      //   'members': FieldValue.arrayUnion([uid + '_' + userName])
      // });
    }
  }

//adminaccept user request

// toggling the user group join
  Future acceptingGroupRequest(
      String groupId, String groupName, String userName) async {
    bool istrue = false;
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference groupDocRef = groupCollection.document(groupId);

    List<dynamic> groups = await userDocSnapshot.data['groups'];

    //print('nay');

    await userDocRef.updateData({
      'groups': FieldValue.arrayUnion([groupId + '_' + groupName])
    });

    await groupDocRef.updateData({
      'members': FieldValue.arrayUnion([uid + '_' + userName])
    });
  }

//delete groups

  Future deletergroup(String groupId, String groupName, String usertype) async {
    print("the uid is $uid and group id is $groupId");
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (usertype == "Manager") {
      var jobskill_query = await FirebaseFirestore.instance
          .collection('groups')
          .where('groupId', isEqualTo: groupId)
          .getx();

      jobskill_query.documents.forEach((element) {
        element.reference.delete();
      });
      await userDocRef.updateData({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
      });
      Fluttertoast.showToast(msg: "Successful");
    } else {
      await userDocRef.updateData({
        'groups': FieldValue.arrayRemove([groupId + '_' + groupName])
      });
      Fluttertoast.showToast(msg: "Successful");
    }
  }

  ///deleting group request
  ///

  Future deletegrouprequests(String groupid, String groupname, action) async {
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    var jobskill_query = await FirebaseFirestore.instance
        .collection('grouprequests')
        .where('groupid', isEqualTo: groupid)
        .get();

    jobskill_query.documents.forEach((element) {
      element.reference.delete();
    });
    Fluttertoast.showToast(msg: "Successful");

    if (action == "decline") {
      await userDocRef.updateData({
        'groups': FieldValue.arrayRemove([groupid + '_' + groupname])
      });

      Fluttertoast.showToast(msg: "Successful");
    }
  }

  Future deleterequests(String tripId, String groupId, String tripName,
      String userName, dynamic index, bool isjoined, action) async {
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();
    if (isjoined) {
      var jobskill_query = await FirebaseFirestore.instance
          .collection('pending requests')
          .where('tripId', isEqualTo: tripId)
          .get();

      jobskill_query.documents.forEach((element) {
        element.reference.delete();
      });

      if (action == "decline") {
        await userDocRef.updateData({
          'trips': FieldValue.arrayRemove([tripId + '_' + tripName])
        });
      }
      Fluttertoast.showToast(msg: "Successful");
    }
  }

  ///get tripgroup
  ///
  gettripgroup(email, tripgroup) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: email)
        .where('tripgroup', isEqualTo: tripgroup)
        .get();
  }

  ///pending trip requests
  ///
  Future pendingrequests(
      String tripId,
      String groupId,
      String tripName,
      String userName,
      dynamic index,
      bool isjoined,
      username,
      groupName) async {
    print("im joinging");
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference tripDocRef =
        tripsCollection.document(groupId).collection('trips').document(tripId);

    List<dynamic> trips = await userDocSnapshot.data['trips'];

    if (trips.contains(tripId + '_' + tripName)) {
      //print('hey');
      await userDocRef.updateData({
        'trips': FieldValue.arrayRemove([tripId + '_' + tripName])
      });

      await tripDocRef.updateData({
        'members': FieldValue.arrayRemove([uid + '_' + userName])
      });
    } else {
      print("updating");
      if (isjoined) {
        var jobskill_query = await FirebaseFirestore.instance
            .collection('pending requests')
            .where('index', isEqualTo: index)
            .get();

        jobskill_query.documents.forEach((element) {
          element.reference.delete();
        });
        Fluttertoast.showToast(msg: "Your request has been removed");
      } else {
        await FirebaseFirestore.instance.collection('pending requests').add({
          "status": "pending",
          "groupid": groupId,
          "userid": uid,
          "username": username,
          "tripId": tripId,
          "tripname": tripName,
          "index": index,
          "isjoined": isjoined,
          "groupname": groupName,
          "groupidandtrip": groupId + '_' + tripId,
        });

        Fluttertoast.showToast(
            msg: "Please wait for admin to approve your request");
      }

      //print('nay');
      // await userDocRef.updateData({
      //   'trips': FieldValue.arrayUnion([tripId + '_' + tripName])
      // });

      // await tripDocRef.updateData({
      //   'members': FieldValue.arrayUnion([uid + '_' + userName])
      // });
    }
  }

  // toggling the user trip join
  Future togglingTripJoin(
      String tripId, String groupId, String tripName, String userName) async {
    print("im joinging");
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    DocumentReference tripDocRef =
        tripsCollection.document(groupId).collection('trips').document(tripId);

    List<dynamic> trips = await userDocSnapshot.data['trips'];

    if (trips.contains(tripId + '_' + tripName)) {
      //print('hey');
      await userDocRef.updateData({
        'trips': FieldValue.arrayRemove([tripId + '_' + tripName])
      });

      await tripDocRef.updateData({
        'members': FieldValue.arrayRemove([uid + '_' + userName])
      });
    } else {
      print("updating");
      //print('nay');
      await userDocRef.updateData({
        'trips': FieldValue.arrayUnion([tripId + '_' + tripName])
      });

      await tripDocRef.updateData({
        'members': FieldValue.arrayUnion([uid + '_' + userName])
      });
    }
  }

  // has user joined the group
  Future<bool> isUserJoined(
      String groupId, String groupName, String userName) async {
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    List<dynamic> groups = await userDocSnapshot.data['groups'];

    if (groups.contains(groupId + '_' + groupName)) {
      //print('he');
      return true;
    } else {
      //print('ne');
      return false;
    }
  }

  // has user joined the trip
  Future<bool> isUserJoinedTrip(
      String tripId, String tripName, String userName) async {
    DocumentReference userDocRef = userCollection.document(uid);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.data['trips'].isNotEmpty) {
      List<dynamic> trips = await userDocSnapshot.data['trips'];

      if (trips.contains(tripId + '_' + tripName)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  // get user data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).getDocuments();
    print(snapshot.documents[0].data);
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return FirebaseFirestore.instance.collection("users").document(uid).snapshots();
  }

  getpendingGroups() async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return FirebaseFirestore.instance
        .collection('grouprequests')
        .where("userid", isEqualTo: uid)
        .snapshots();
  }
//get pending group requests //admi

  getpendingGroupsrequests(groupid) async {
    print("the group id is $groupid");
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return FirebaseFirestore.instance
        .collection('grouprequests')
        .where("groupid", isEqualTo: groupid)
        .snapshots();
  }

  ///get user trips
  ///

  getUserTrip() async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return FirebaseFirestore.instance.collection("users").document(uid).snapshots();
  }

  getUserdetails() async {
    // return await Firestore.instance.collection("users").where('email', isEqualTo: email).snapshots();
    return FirebaseFirestore.instance.collection("users").document(uid).get();
  }

  // send message
  sendMessage(String groupId, chatMessageData) {
    FirebaseFirestore.instance
        .collection('groups')
        .document(groupId)
        .collection('messages')
        .add(chatMessageData);
    FirebaseFirestore.instance.collection('groups').document(groupId).updateData({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  // get chats of a particular group
  getChats(String groupId) async {
    return FirebaseFirestore.instance
        .collection('groups')
        .document(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  // get pendingrequests of a particular group
  getpendingrequests(String groupId) async {
    return FirebaseFirestore.instance
        .collection('pending requests')
        .where("groupid", isEqualTo: groupId)
        .snapshots();
  }

  ///get pending grouprequests
  ///

  ///get pending request document
  ///
  getpendingrequestsdoc(String groupid) async {
    return FirebaseFirestore.instance
        .collection('pending requests')
        .where("groupid", isEqualTo: groupid)
        .get();
  }

  getpendingrequestsdoc2(String groupid, userid) async {
    return FirebaseFirestore.instance
        .collection('pending requests')
        .where("groupid", isEqualTo: groupid)
        .where('userid', isEqualTo: userid)
        .get();
  }
//make trips

  gettrips(String groupId) async {
    return FirebaseFirestore.instance
        .collection('groups')
        .document(groupId)
        .collection('trips')
        .orderBy('time')
        .snapshots();
  }

  gettrips2(String groupId) async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .document(groupId)
        .collection('trips')
        .snapshots();
  }

  // search groups
  searchByName(String groupName) {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupName', isEqualTo: groupName)
        .get();
  }
}
