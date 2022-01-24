import 'package:app/constants/strings.dart';
import 'package:app/models/http_exception_model.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/theme_provider.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditDataScreen extends StatefulWidget {
  const EditDataScreen({Key? key}) : super(key: key);

  @override
  State<EditDataScreen> createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  String _password = "";
  String _confirmPassword = "";
  bool _isPasswordVisibility = false;
  bool _isConfirmPasswordVisibility = false;
  bool _isLoading = false;

  void _editPassword(AuthProvider auth) async {
    FocusScope.of(context).unfocus();
    if (_passwordFormKey.currentState!.validate()) {
      _passwordFormKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        await auth.changePassword(context, _password);
      } on HttpException catch (error) {
        showInfoAlertDialog(
            context, auth.handleAuthenticationError(error), true);
      } catch (error) {
        print(error);
        showInfoAlertDialog(context, strings['unknown_error']!, true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: true);
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      alignment: Alignment.topCenter,
      width: size.width,
      height: size.height * .8,
      padding: EdgeInsets.only(
          left: size.width * .1,
          right: size.width * .1,
          bottom: size.height * .05,
          top: size.height * .1),
      child: SingleChildScrollView(
        child: Form(
            key: _passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntrinsicHeight(
                  child: TextFormField(
                    obscureText: !_isPasswordVisibility,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    style: TextStyle(fontSize: size.width * 0.04),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(
                          size.height * .02,
                          size.height * .02,
                          size.height * .02,
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
                              _isPasswordVisibility = !_isPasswordVisibility;
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
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: theme.themeAccent,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            )),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            )),
                        labelText: strings["form_password"]),
                    keyboardType: TextInputType.text,
                    onSaved: (value) {
                      setState(() {
                        _password = value!.trim();
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _password = value.trim();
                      });
                    },
                    validator: (value) {
                      if (value!.trim().isEmpty || value.trim().length < 8) {
                        return strings["form_password_validate"];
                      } else if (_password != _confirmPassword) {
                        return strings["form_password_confirmed_validate"];
                      }
                      return null;
                    },
                  ),
                ),
                VerticalSpace(size: size, percentage: 0.03),
                IntrinsicHeight(
                  child: TextFormField(
                    obscureText: !_isConfirmPasswordVisibility,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    style: TextStyle(fontSize: size.width * 0.04),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(
                          size.height * .02,
                          size.height * .02,
                          size.height * .02,
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
                              _isConfirmPasswordVisibility =
                                  !_isConfirmPasswordVisibility;
                            });
                          },
                          child: Icon(
                            _isConfirmPasswordVisibility
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: size.width * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: theme.themeAccent,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            )),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.red,
                            )),
                        labelText: strings["form_confirm_password"]),
                    keyboardType: TextInputType.text,
                    onSaved: (value) {
                      setState(() {
                        _confirmPassword = value!.trim();
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value.trim();
                      });
                    },
                    validator: (value) {
                      if (value!.trim().isEmpty || value.trim().length < 8) {
                        return strings["form_password_validate"];
                      } else if (_password != _confirmPassword) {
                        return strings["form_password_confirmed_validate"];
                      }
                      return null;
                    },
                  ),
                ),
                VerticalSpace(size: size, percentage: 0.05),
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
                                      borderRadius: BorderRadius.circular(8))),
                            ),
                            onPressed: () => _editPassword(auth),
                            child: Text(
                              strings['change_password']!,
                              style: TextStyle(
                                  fontSize: size.height * .025,
                                  color: Colors.white),
                            )),
                      ),
              ],
            )),
      ),
    );
  }
}
