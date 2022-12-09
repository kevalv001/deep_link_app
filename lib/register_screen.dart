import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'dashboard_screen.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage(
      {Key? key, required this.title, this.referralCode, this.referralUserId})
      : super(key: key);
  final String title;
  final String? referralCode;
  final String? referralUserId;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  bool isLoading = false;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController referralCode = TextEditingController();
  TextEditingController password = TextEditingController();
  final box = GetStorage();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    referralCode.text = widget.referralCode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      body: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Sign up',
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                            maxLines: 1,
                            controller: firstName,
                            decoration: InputDecoration(
                              hintText: 'First name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                            maxLines: 1,
                            controller: lastName,
                            decoration: InputDecoration(
                              hintText: 'Last name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
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
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      maxLines: 1,
                      controller: referralCode,
                      decoration: InputDecoration(
                        hintText: 'Enter referral code (Optional)',
                        prefixIcon: const Icon(Icons.code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            final credential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: email.text,
                              password: password.text,
                            );
                            if (credential.user?.uid != null) {
                              box.write('uuid', credential.user?.uid);
                              await addUserData(credential.user?.uid ?? "");
                              if (widget.referralCode != null &&
                                  widget.referralUserId != null) {
                                await _updateReferralWallet();
                              }
                              setState(() {
                                isLoading = false;
                              });
                              Future.delayed(Duration.zero).whenComplete(() =>
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return const DashboardScreen();
                                    },
                                  )));
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              print('The password provided is too weak.');
                            } else if (e.code == 'email-already-in-use') {
                              print(
                                  'The account already exists for that email.');
                            }
                            setState(() {
                              isLoading = false;
                            });
                          } catch (e) {
                            print(e);
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator())
                          : const Text(
                              'Sign up',
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
                        const Text('Already registered?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginPage(title: 'Login UI'),
                              ),
                            );
                          },
                          child: const Text('Sign in'),
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

  _updateReferralWallet() async {
    Map<String, dynamic>? documentData;
    await users
        .where('userId', isEqualTo: widget.referralUserId)
        .get()
        .then((event) async {
      if (event.docs.isNotEmpty) {
        documentData = event.docs.single.data() as Map<String, dynamic>?;
        print(documentData?["wallet"]);
        await users
            .doc(widget.referralUserId)
            .update({'wallet': documentData?["wallet"] + 10});
      }
    }).catchError((e) => null);
  }

  addUserData(String userID) async {
    DocumentReference documentReferencer = users.doc(userID);
    await documentReferencer
        .set({"userId": userID, "wallet": 10, "name": firstName.text})
        .whenComplete(() => print(" !!!!!!!   user register !!!!!!! "))
        .catchError((e) => print("Print :$e"));
  }
}
