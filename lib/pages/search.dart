import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttersharenew/models/user.dart';
import 'package:fluttersharenew/pages/home.dart';
import 'package:fluttersharenew/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("displayName", isGreaterThanOrEqualTo: query).get();

    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    AppBar buildSearchField() {
      return AppBar(
        backgroundColor: Colors.white,
        title: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
              hintText: "Search for a user...",
              filled: true,
              prefixIcon: Icon(
                Icons.account_box,
                size: 28.0,
              ),
              suffixIcon: IconButton(
                  onPressed: () => clearSearch, icon: Icon(Icons.clear))),
          onFieldSubmitted: handleSearch,
        ),
      );
    }

    Container builNoContent() {
      final Orientation orientation = MediaQuery.of(context).orientation;
      return Container(
        child: Container(
          child: ListView(
            shrinkWrap: true,
            children: [
              SvgPicture.asset(
                'assets/images/search.svg',
                height: orientation == Orientation.portrait ? 300.0 : 200.0,
              ),
              Text(
                'Find Users',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  fontSize: 60.0,
                ),
              )
            ],
          ),
        ),
      );
    }

    buildsearchResults() {
      return FutureBuilder(
          future: searchResultsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            List<UserResult> searchResults = [];
            snapshot.data.docs.forEach((docs) {
              User user = User.fromDocument(docs);
              UserResult searchResult = UserResult(user);
              searchResults.add(searchResult);
            });
            return ListView(
              children: searchResults,
            );
          });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? builNoContent() : buildsearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => print('tapped'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}
