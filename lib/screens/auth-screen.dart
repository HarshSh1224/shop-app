import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/screens/product_overview_screen.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 121, 30, 233).withOpacity(0.5),
                  Color.fromARGB(255, 81, 30, 233).withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  void _showErrorDialog(String errorMessage) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('An Error Occurred'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Okay'))
            ],
          );
        });
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .signin(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication Error';

      String errorString = error.toString();

      if (errorString.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email';
      }
      if (errorString.contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      }
      if (errorString.contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
      }
      if (errorString.contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      }
      if (errorString.contains('WEAK_PASSWORD')) {
        errorMessage = 'Your password is too weak, try a strong password';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Couldn\'t authenticate you. Please try again later';
      _showErrorDialog(errorMessage);
    }
    // finally {
    // Navigator.of(context).pushReplacementNamed(ProductOverview.routeName);

    // }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 1 / 25,
        ),
        Container(
            height: 150,
            width: 150,
            child: Card(
              elevation: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'assets/images/logo.png',
                ),
              ),
            )),
        SizedBox(
          height: 30,
        ),
        Container(
          width: MediaQuery.of(context).size.width - 20,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 8.0,
            child: Container(
              height: _authMode == AuthMode.Signup ? 500 : 430,
              // width: MediaQuery.of(context).
              constraints: BoxConstraints(
                  minHeight: _authMode == AuthMode.Signup ? 320 : 260),
              width: deviceSize.width * 0.75,
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                          style: TextStyle(
                              fontFamily: 'Anton',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5)),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'E-Mail'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Invalid email!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _authData['email'] = value!;
                        },
                      ),
                      if (_authMode == AuthMode.Login) SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 5) {
                            return 'Password is too short!';
                          }
                        },
                        onSaved: (value) {
                          _authData['password'] = value!;
                        },
                      ),
                      if (_authMode == AuthMode.Signup)
                        TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                }
                              : null,
                        ),
                      SizedBox(
                        height: 40,
                      ),
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        ElevatedButton(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: MediaQuery.of(context).size.width * 3/12),
                            child: Text(_authMode == AuthMode.Login
                                ? 'LOGIN'
                                : 'SIGN UP'),
                          ),
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 8.0),
                            backgroundColor: Color.fromARGB(211, 61, 17, 239),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        child: Text(
                            '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                        onPressed: _switchAuthMode,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 4),
                          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Color.fromARGB(211, 61, 17, 239),
                        ),
                      ),
                      // SizedBox(height: 40,)
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
