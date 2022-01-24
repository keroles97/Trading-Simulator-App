import 'package:app/constants/strings.dart';
import 'package:app/models/http_exception_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/widgets/privacy_policy_dialog.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SignInSignUpScreen extends StatefulWidget {
  const SignInSignUpScreen({Key? key}) : super(key: key);

  @override
  _SignInSignUpScreenState createState() => _SignInSignUpScreenState();
}

class _SignInSignUpScreenState extends State<SignInSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _name = "";
  String _email = "";
  String _password = "";
  bool _isPasswordVisibility = false;
  bool _isLoading = false;
  bool _isResetPassword = false;
  bool _isSignIn = true;

  void _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isResetPassword = false;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final db = Provider.of<DatabaseProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        _formKey.currentState!.save();
        if (_isSignIn) {
          await auth.signIn(context, _email, _password);
        } else {
          List<String> data = await auth.signUp(context, _email, _password);
          db.getUserAuthData(data[0], data[1]);
          await _createUser(db);
          setState(() {
            _isSignIn = true;
          });
        }
      } on HttpException catch (error) {
        showInfoAlertDialog(
            context, auth.handleAuthenticationError(error), true);
      } catch (error) {
        print(error.toString());
        showInfoAlertDialog(context, strings['unknown_error']!, true);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _createUser(DatabaseProvider db) async {
    var user = UserModel(
      name: _name,
      email: _email,
      uId: db.uId,
      token: db.token,
    );
    try {
      await db.addUserData('users/${db.uId}', user.toMap());
    } on HttpException {
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  void _resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isResetPassword = true;
    });
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        _formKey.currentState!.save();
        await auth.sendResetPasswordEmail(context, _email);
      } on HttpException catch (error) {
        showInfoAlertDialog(
            context, auth.handleAuthenticationError(error), true);
      } catch (error) {
        print(error);
        showInfoAlertDialog(context, strings['unknown_error']!, true);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    return SingleChildScrollView(
      child: SizedBox(
        width: size.width,
        height: size.height - (size.height * .25),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * .03),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    strings[_isSignIn ? "sign_in" : "sign_up"]!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.themeAccent,
                        fontSize: size.width * 0.08),
                  ),
                  VerticalSpace(size: size, percentage: 0.01),
                  Text(
                    strings["sign_in_sub_header"]!,
                    style: TextStyle(fontSize: size.width * 0.03),
                  ),
                ],
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!_isSignIn)
                        IntrinsicHeight(
                          child: TextFormField(
                            minLines: 1,
                            style: TextStyle(fontSize: size.width * 0.04),
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(
                                  size.height * .02,
                                  size.height * .02,
                                  size.height * .01,
                                  size.height * .02,
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  size: size.width * 0.04,
                                  color: Colors.grey,
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    )),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: theme.themeAccent,
                                    )),
                                labelText: strings["form_name"]!),
                            keyboardType: TextInputType.name,
                            onSaved: (value) {
                              setState(() {
                                _name = value!;
                              });
                            },
                            validator: (value) {
                              if (!_isSignIn &&
                                  (value!.trim().isEmpty ||
                                      value.trim().length < 3)) {
                                return strings["form_name_validate"]!;
                              }
                              return null;
                            },
                          ),
                        ),
                      VerticalSpace(size: size, percentage: 0.02),
                      IntrinsicHeight(
                        child: TextFormField(
                          controller: _emailController,
                          maxLines: 1,
                          style: TextStyle(fontSize: size.width * 0.04),
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(
                                size.height * .02,
                                size.height * .02,
                                size.height * .01,
                                size.height * .02,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                size: size.width * 0.04,
                                color: Colors.grey,
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  )),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.themeAccent,
                                  )),
                              labelText: strings["form_email"]!),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) {
                            setState(() {
                              _email = value!.trim();
                            });
                          },
                          validator: (value) {
                            if (value!.trim().isEmpty ||
                                !value.contains("@") ||
                                value.trim().length < 5) {
                              return strings["form_email_validate"]!;
                            }
                            return null;
                          },
                        ),
                      ),
                      VerticalSpace(size: size, percentage: 0.02),
                      IntrinsicHeight(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisibility,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          style: TextStyle(fontSize: size.width * 0.04),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(
                                size.height * .02,
                                size.height * .02,
                                size.height * .01,
                                size.height * .02,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                size: size.width * 0.04,
                                color: Colors.grey,
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isPasswordVisibility =
                                        !_isPasswordVisibility;
                                  });
                                },
                                child: Icon(
                                  _isPasswordVisibility
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: size.width * 0.04,
                                  color: Colors.grey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  )),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: theme.themeAccent,
                                  )),
                              labelText: strings["form_password"]!),
                          keyboardType: TextInputType.text,
                          onSaved: (value) {
                            setState(() {
                              _password = value!.trim();
                            });
                          },
                          validator: (value) {
                            if (!_isResetPassword &&
                                (value!.trim().isEmpty ||
                                    value.trim().length < 8)) {
                              return strings["form_password_validate"]!;
                            }
                            return null;
                          },
                        ),
                      ),
                      VerticalSpace(size: size, percentage: 0.04),
                      _isLoading
                          ? const CircularProgressIndicator.adaptive()
                          : Container(
                              width: size.width,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * .05, vertical: 0),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.symmetric(
                                            vertical: size.height * .01)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                  ),
                                  onPressed: () => _submit(),
                                  child: Text(
                                    strings[_isSignIn ? "sign_in" : "sign_up"]!,
                                    style: TextStyle(
                                        fontSize: size.height * .025,
                                        color: Colors.white),
                                  )),
                            ),
                      VerticalSpace(size: size, percentage: 0.04),
                      if (_isSignIn)
                        TextButton(
                            onPressed: () => _resetPassword(),
                            child: Text(
                              strings["forget_password"]!,
                              style: TextStyle(fontSize: size.height * 0.02),
                            )),
                    ],
                  )),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    strings[_isSignIn ? "not_member" : "already_member"]!,
                    style: TextStyle(fontSize: size.width * 0.03),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        strings[_isSignIn ? "sign_up" : "sign_in"]!,
                        style: TextStyle(
                            color: theme.themeAccent,
                            fontSize: size.height * 0.02),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _isSignIn = !_isSignIn;
                      });
                    },
                  )
                ],
              ),
              if(!_isSignIn)
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      strings["privacy_policy_message"]!,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                          color: theme.themeAccent, fontSize: size.height * 0.02),
                    ),
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          return PrivacyPolicyDialog(
                            size: size,
                            theme: theme,
                          );
                        });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
