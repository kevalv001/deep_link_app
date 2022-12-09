import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final box = GetStorage();
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Sign in',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) => EmailValidator.validate(value!)
                          ? null
                          : "Please enter a valid email",
                      maxLines: 1,
                      controller: email,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      maxLines: 1,
                      obscureText: true,
                      controller: password,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: 'Enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      title: const Text("Remember me"),
                      contentPadding: EdgeInsets.zero,
                      value: rememberValue,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (newValue) {
                        setState(() {
                          rememberValue = newValue!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _handleLogin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                      ),
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Not registered yet?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterPage(title: 'Register UI'),
                              ),
                            );
                          },
                          child: const Text('Create an account'),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _handleLogin() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
      if (credential.user?.uid != null) {
        box.write('uuid', credential.user?.uid);

        setState(() {
          //  isLoading = false;
        });
        Future.delayed(Duration.zero)
            .whenComplete(() => Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const DashboardScreen();
                  },
                )));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> initDynamicLinks() async {
    var data = await FirebaseDynamicLinks.instance.getInitialLink();
    var deepLink = data;
    String? uuid = box.read('uuid');

    /// When app is killed state
    if (deepLink != null) {
      print(deepLink.link.path);
      print(deepLink.link.queryParameters);
      if (uuid != null && uuid != "") {
        Timer(
            const Duration(seconds: 0),
            () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) {
                    return const DashboardScreen(
                      firstName: "",
                    );
                  },
                ), (route) => false));
      } else {
        Timer(
            const Duration(seconds: 0),
            () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return RegisterPage(
                      referralCode: deepLink.link.queryParameters['code'],
                      referralUserId: deepLink.link.queryParameters['userId'],
                      title: 'Register',
                    );
                  },
                )));
      }
    }

    /// When app is live and background state
    dynamicLinks.onLink.listen((dynamicLinkData) {
      print("---------------------------------");
      print(dynamicLinkData.link.path);
      print(dynamicLinkData.link.queryParameters);
      if (uuid != null && uuid != "") {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return const DashboardScreen(
              firstName: "",
            );
          },
        ), (route) => false);
      } else {
        if (mounted) {
          Timer(
              const Duration(seconds: 0),
              () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return RegisterPage(
                        referralCode:
                            dynamicLinkData.link.queryParameters['code'],
                        title: 'Register',
                        referralUserId:
                            dynamicLinkData.link.queryParameters['userId'],
                      );
                    },
                  )));
        }
      }
    }).onError((error) {
      print('onLink error');
      print(error.message);
    });
  }
}
