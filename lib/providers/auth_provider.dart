import 'dart:async';
import 'dart:convert';

import 'package:app/constants/strings.dart';
import 'package:app/models/http_exception_model.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _uId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get uId => _uId;

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String _authApi(String urlSegment) {
    return 'https://identitytoolkit.googleapis.com/v1/accounts'
        ':$urlSegment?key=AIzaSyA8vB0cQQoXRBstVTmW8zJXZob0803I6fY';
  }

  Future<List<String>> signUp(
      BuildContext context, String email, String password) async {
    try {
      final res = await http.post(Uri.parse(_authApi('signUp')),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        print('signUp' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      await sendEmailVerification(context, resData['idToken']);
      return [resData['idToken'], resData['localId']];
    } catch (e) {
      print('signUp' + e.toString());
      rethrow;
    }
  }

  Future<void> signIn(BuildContext context, String email, String password) async {
    try {
      final res = await http.post(Uri.parse(_authApi('signInWithPassword')),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        print('signIn' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      if (await checkEmailVerification(resData['idToken'])) {
        _token = resData['idToken'];
        _uId = resData['localId'];
        _expiryDate = DateTime.now()
            .add(Duration(seconds: int.parse(resData['expiresIn'])));
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        String userData = json.encode({
          'token': _token,
          'uId': _uId,
          'expiryDate': _expiryDate!.toIso8601String(),
        });
        prefs.setString('userData', userData);
        _autoSignOut();
      } else {
        await sendEmailVerification(context, resData['idToken']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkEmailVerification(String token) async {
    try {
      final res = await http.post(Uri.parse(_authApi('lookup')),
          body: json.encode({
            'idToken': token,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        print('checkEmailVerification' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      return resData['users'][0]['emailVerified'];
    } catch (e) {
      print('checkEmailVerification' + e.toString());
      rethrow;
    }
  }

  Future<void> sendEmailVerification(BuildContext context, String token) async {
    try {
      final res = await http.post(Uri.parse(_authApi('sendOobCode')),
          body: json.encode({
            'requestType': 'VERIFY_EMAIL',
            'idToken': token,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        print('sendEmailVerification' + resData['error'].toString());

        throw HttpException(resData['error']['message']);
      }
      showInfoAlertDialog(context, strings['email_verification_sent']!, false);
    } catch (e) {
      print('sendEmailVerification' + e.toString());
      rethrow;
    }
  }

  Future<void> sendResetPasswordEmail(
      BuildContext context, String email) async {
    try {
      final res = await http.post(Uri.parse(_authApi('sendOobCode')),
          body: json.encode({
            'requestType': 'PASSWORD_RESET',
            'email': email,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        print('sendResetPasswordEmail' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      showInfoAlertDialog(
          context, strings['reset_password_email_sent']!, false);
    } catch (e) {
      print('sendResetPasswordEmail' + e.toString());
      rethrow;
    }
  }

  Future<void> tryAutoSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) return;
    final Map<String, dynamic> userData =
        json.decode(prefs.getString("userData")!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return;
    _token = userData['token'].toString();
    _uId = userData['uId'].toString();
    _expiryDate = expiryDate;
    _autoSignOut();
    notifyListeners();
  }

  void _autoSignOut() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), signOut);
  }

  Future<void> signOut() async {
    _token = null;
    _uId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  Future<void> changePassword(BuildContext context, String password) async {
    try {
      final res = await http.post(Uri.parse(_authApi('update')),
          body: json.encode({
            'idToken': token,
            'password': password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      if (resData['error'] != null) {
        print('changePassword' + resData['error'].toString());
        throw HttpException(resData['error']['message']);
      }
      showInfoAlertDialog(context, strings['succeed']!, false);
      await signOut();
    } catch (e) {
      print('changePassword' + e.toString());
      rethrow;
    }
  }

  String handleAuthenticationError(HttpException error) {
    String message = error.toString();
    if (message.contains("EMAIL_EXISTS")) {
      return strings['already_signed_up']!;
    } else if (message.contains('INVALID_EMAIL')) {
      return strings['invalid_email']!;
    } else if (message.contains('INVALID_PASSWORD')) {
      return strings['wrong_password']!;
    } else if (message.contains('EMAIL_NOT_FOUND')) {
      return strings['email_not_found']!;
    } else if (message.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return strings['too_many_attempts']!;
    } else if (message.contains('INVALID_ID_TOKEN')) {
      return strings['requires-recent-login']!;
    }else if (message.contains('CREDENTIAL_TOO_OLD_LOGIN_AGAIN')) {
      return strings['requires-recent-login']!;
    }
    print('handleAuthenticationError' + error.toString());
    return message;
  }
}
