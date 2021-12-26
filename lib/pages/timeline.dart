import 'package:flutter/material.dart';
import 'package:fluttersharenew/pages/home.dart';
import 'package:fluttersharenew/widgets/header.dart';
import 'package:fluttersharenew/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

//final usersRef = FirebaseFirestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: linearProgress(),
    );
  }

  @override
  void initState() {
    getData();
    createUser();

    // getUsers();
    //getUserById();
    super.initState();
  }

  createUser() {
    usersRef.doc("asdasd").set({
      "username": "jeff",
      "postsCount": 0,
      "isAdmin": false,
    });
  }

  getData() async {
    CollectionReference usersref =
        FirebaseFirestore.instance.collection("users");
    QuerySnapshot querySnapshot = await usersref.get();

    List<QueryDocumentSnapshot> Listdocs = querySnapshot.docs;

    Listdocs.forEach((element) {
      print(element.data());
      print("====================");
    });
  }
}


  /* getUsers() {
    usersRef.doc().then((QuerySnapshot snapshot) {
      snapshot.documents.foreach((DocumentSnapshot doc) {
        print(doc.data);
        print(doc.documentID);
        print(doc.exists)
      });
    });
  }
  */

  /*getUserById() async {
    final String id = "uSoxY0rol76H68D9Z1ug";
    final DocumentSnapshot await usersRef.doc(id).get().then((DocumentSnapshot doc ){
       print(doc.data);
        print(doc.documentID);
        print(doc.exists);


    });
  }*/

