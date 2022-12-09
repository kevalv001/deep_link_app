import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'login_page.dart';

class DashboardScreen extends StatefulWidget {
  final String? firstName;

  const DashboardScreen({Key? key, this.firstName}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  String? _deepLink;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 15,
                left: 20,
                bottom: 20,
                right: 20),
            decoration: const BoxDecoration(
                color: Color(0xff121212),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where('userId', isEqualTo: box.read('uuid'))
                    .snapshots(),
                builder: (context, snapshot) {
                  print(snapshot.data?.docs.single.data());
                  Map<String, dynamic>? data =
                      snapshot.data?.docs.single.data();
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            box.erase();
                            Future.delayed(const Duration(seconds: 1)).then(
                                (value) => Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(
                                      builder: (context) {
                                        return const LoginPage(
                                          title: "",
                                        );
                                      },
                                    ), (route) => false));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "HI, ${data?["name"] ?? ""}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Good morning",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Wallet balance \$${data?["wallet"] ?? 0}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ]);
                }),
          ),
          const Expanded(
              child: WebView(
            initialUrl: 'http://www.techienutzitservices.com/',
          )),
        ]),
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: _deepLink));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied Link!')),
          );
        },
        child: FloatingActionButton.extended(
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            await _createDynamicLink();
            print(_deepLink);
            if (_deepLink != null) {
              Share.share(_deepLink!);
            }
          },
          icon: const Icon(
            Icons.share,
            color: Colors.white,
          ),
          label: const Text(
            "Share referral code",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://croudoperationapp.page.link',
      link: Uri.parse(
          "https://virendeep.com/referral?code=12345&userId=${box.read('uuid')}"),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.deep_link_demo_app',
        minimumVersion: 0,
      ),
    );

    Uri url;

    final ShortDynamicLink shortLink =
        await dynamicLinks.buildShortLink(parameters);
    url = shortLink.shortUrl;
    setState(() {
      _deepLink = url.toString();
    });
  }

}
