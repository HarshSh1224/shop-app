import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _timer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCRPd0fZxZUiS-dENQ8oSphyLyE7S9Dgzk');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final extractedData = json.decode(response.body);
      if (extractedData['error'] != null) {
        throw HttpException(json.decode(response.body)['error']['message']);
      }

      _token = extractedData['idToken'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(extractedData['expiresIn'])));
      _userId = extractedData['localId'];
      _autoLogOut();
      notifyListeners();
      // final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      });

      // prefs.setString('userData', userData);
      final dataInstance = await GetStorage();
      dataInstance.write('userData', userData);
      print('put instance');
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    try { final userData = await GetStorage();
    userData.writeIfNull('userData', 'value');
    if (userData.read('userData') == 'value') {
      print('Not found instance');
      return false;
    }
    final extractedData =
        json.decode(userData.read('userData')) as Map<String, dynamic>;

    // await Future.delayed(Duration(seconds: 4));
    // final prefs = await SharedPreferences.getInstance();
    // if (!prefs.containsKey('userData')) {
    // print('Not found instance');
    //   return false;
    // }
    // print('found instance');
    // final extractedData =
    //     json.decode(prefs.getString('userData') ?? '') as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      print('Expired');
      return false;
    }
    _token = extractedData['token'] as String;
    _userId = extractedData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogOut();
    print('found instance');
    return true;} catch(error){
      print(error.toString());
      return false;
    }
  }

  String get userId {
    return _userId ?? '';
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logOut() async {
    _expiryDate = null;
    _token = null;
    _userId = null;
    if (_timer != null) _timer!.cancel();
    final prefs = GetStorage();
    prefs.remove('userData');
    notifyListeners();
  }

  void _autoLogOut() {
    if (_timer != null) {
      _timer!.cancel();
    }
    final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _timer = Timer(Duration(seconds: timeToExpire), logOut);
  }
}
