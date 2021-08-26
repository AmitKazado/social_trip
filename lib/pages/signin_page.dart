import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:social_trip/controllers/helper/helper_functions.dart';
import 'package:social_trip/pages/Dashboard.dart';
import 'package:social_trip/pages/home_page.dart';
import 'package:social_trip/controllers/services/auth_service.dart';
import 'package:social_trip/controllers/services/database_service.dart';
import 'package:social_trip/controllers/shared/constants.dart';
import 'package:social_trip/controllers/shared/loading.dart';

class SignInPage extends StatefulWidget {
  final Function toggleView;
  SignInPage({this.toggleView});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  _onSignIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .signInWithEmailAndPassword(email.trim(), password)
          .then((result) async {
        if (result != null) {
          QuerySnapshot userInfoSnapshot =
              await DatabaseService().getUserData(email.trim());

          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email.trim());
          await HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.docs[0]['fullName']);

          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Dashboard()));
        } else {
          setState(() {
            error = 'Error signing in!';
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: Container(
                  //   color: Color(0xff1b6535),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/background.jfif',
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.fill,
                      ),
                      ListView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 80.0),
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                  child: Text("Welcome to Social Trip",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40.0,
                                          fontWeight: FontWeight.bold))),
                              SizedBox(height: 30.0),
                              Text("Sign In",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25.0)),
                              SizedBox(height: 20.0),
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                decoration: textInputDecoration.copyWith(
                                    labelText: 'Email'),
                                validator: (val) {
                                  return RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(val)
                                      ? null
                                      : "Please enter a valid email";
                                },
                                onChanged: (val) {
                                  setState(() {
                                    email = val;
                                  });
                                },
                              ),
                              SizedBox(height: 15.0),
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                decoration: textInputDecoration.copyWith(
                                    labelText: 'Password'),
                                validator: (val) => val.length < 6
                                    ? 'Password not strong enough'
                                    : null,
                                obscureText: true,
                                onChanged: (val) {
                                  setState(() {
                                    password = val;
                                  });
                                },
                              ),
                              SizedBox(height: 20.0),
                              SizedBox(
                                width: double.infinity,
                                height: 50.0,
                                child: RaisedButton(
                                    elevation: 0.0,
                                    color: Color(0xffa8c66c),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    child: Text('Sign In',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0)),
                                    onPressed: () {
                                      _onSignIn();
                                    }),
                              ),
                              SizedBox(height: 10.0),
                              Text.rich(
                                TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14.0),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Register here',
                                      style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          widget.toggleView();
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(error,
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 14.0)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
  }
}
