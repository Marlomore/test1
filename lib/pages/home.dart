import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttersharenew/models/user.dart';
import 'package:fluttersharenew/pages/activity_feed.dart';
import 'package:fluttersharenew/pages/create_account.dart';
import 'package:fluttersharenew/pages/profile.dart';
import 'package:fluttersharenew/pages/search.dart';
import 'package:fluttersharenew/pages/timeline.dart';
import 'package:fluttersharenew/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

final GoogleSignIn googleSignIn = GoogleSignIn();
final firebase_storage.Reference storageRef =
    firebase_storage.FirebaseStorage.instance.ref();

final usersRef = FirebaseFirestore.instance.collection('users');
final postsRef = FirebaseFirestore.instance.collection('posts');

final DateTime Timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController pageController;
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }

  bool isAuth = false;

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          //Timeline(),
          RaisedButton(
            onPressed: logout,
            child: Text('Logout'),
          ),
          ActivityFeed(),
          Upload(currentUser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: ontap,
        activeColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  ontap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor,
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'FlutterShare',
              style: TextStyle(
                  fontFamily: 'Signatra', fontSize: 90, color: Colors.white),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/google_signin_button.png'),
                        fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detects when user is signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in : $err');
    });
    //Reauthenicate user when app is reopened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in : $err');
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();

      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // check if user exists in users collection in data base (
    // according to their id  )
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      //2) if the user doesnt exist ,then we want  to take them to the create account page

      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
    }

    //3) get username from create account , use it to make new user document in users collection
    usersRef.doc(user.id).set({
      'id': user.id,
      'username': user.displayName,
      "photoUrl": user.photoUrl,
      "email": user.email,
      "displayName": user.displayName,
      "bio": "",
      "Timestamp": Timestamp,
    });

    doc = await usersRef.doc(user.id).get();

    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }
}
