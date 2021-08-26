import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:social_trip/controllers/helper/helper_functions.dart';
import 'package:social_trip/pages/home_page.dart';
import 'package:social_trip/controllers/services/auth_service.dart';
import 'package:social_trip/controllers/shared/constants.dart';
import 'package:social_trip/controllers/shared/loading.dart';

import '../controllers/helper/helper_functions.dart';
import 'Dashboard.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;
  RegisterPage({this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // text field state
  String fullName = '';
  String email = '';
  String password = '';
  String error = '';

  _onRegister() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .registerWithEmailAndPassword(fullName, email, password, usertype)
          .then((result) async {
        if (result != null) {
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(fullName);
          await HelperFunctions.saveUserTypeSharedPreference(usertype);

          print("Registered");
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
            error = 'Error while registering the user!';
            _isLoading = false;
          });
        }
      });
    }
  }

  String usertype = 'Traveler';
  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            body: Form(
                key: _formKey,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/background.jfif',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.fill,
                    ),
                    Container(
                      // color: Color(0xff1b6535),
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 80.0),
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Welcome to Social Trip",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 30.0),
                              Text("Register",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25.0)),
                              SizedBox(height: 20.0),
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                decoration: textInputDecoration.copyWith(
                                    labelText: 'Full Name'),
                                onChanged: (val) {
                                  setState(() {
                                    fullName = val;
                                  });
                                },
                              ),
                              SizedBox(height: 15.0),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'UserType: ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    height: 50.0,
                                    child: RaisedButton(
                                        elevation: 0.0,
                                        color: usertype == 'Manager'
                                            ? Color(0xffa8c66c)
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        child: Text('Manager',
                                            style: TextStyle(
                                                color: usertype == 'Manager'
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16.0)),
                                        onPressed: () {
                                          setState(() {
                                            usertype = 'Manager';
                                          });
                                        }),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    height: 50.0,
                                    child: RaisedButton(
                                        elevation: 0.0,
                                        color: usertype == 'Traveler'
                                            ? Color(0xffa8c66c)
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0)),
                                        child: Text('Traveler',
                                            style: TextStyle(
                                                color: usertype == 'Traveler'
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16.0)),
                                        onPressed: () {
                                          setState(() {
                                            usertype = 'Traveler';
                                          });
                                        }),
                                  ),
                                ],
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
                                    child: Text('Register',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0)),
                                    onPressed: () {
                                      _onRegister();
                                    }),
                              ),
                              SizedBox(height: 10.0),
                              Text.rich(
                                TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14.0),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Sign In',
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
                    ),
                  ],
                )),
          );
  }
}
