import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_trip/models/user.dart' as Users;
import 'package:social_trip/controllers/helper/helper_functions.dart';

import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  // create user object based on FirebaseUser
  Users.User _userFromFirebaseUser(User user) {
    return (user != null) ?  Users.User(uid: user.uid) : null;
  }


  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }


  // register with email and password
  Future registerWithEmailAndPassword(String fullName, String email, String password,String usertype) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;

      // Create a new document for the user with uid
      await DatabaseService(uid: user.uid).updateUserData(fullName, email, '',usertype);
      return _userFromFirebaseUser(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //sign out
  Future signOut() async {
    try {
      await HelperFunctions.saveUserLoggedInSharedPreference(false);
      await HelperFunctions.saveUserEmailSharedPreference('');
      await HelperFunctions.saveUserNameSharedPreference('');

      return await _auth.signOut().whenComplete(() async {
        print("Logged out");
        await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
          print("Logged in: $value");
        });
        await HelperFunctions.getUserEmailSharedPreference().then((value) {
          print("Email: $value");
        });
        await HelperFunctions.getUserNameSharedPreference().then((value) {
          print("Full Name: $value");
        });
      });
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}