import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/resources/firestore_methods.dart';
import 'package:insta/utils/colors.dart';
import 'package:insta/utils/utils.dart';

import '../widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  ProfileScreen({
    Key? key, required this.uid
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  bool isLoaded = false;
  int postLen = 0;
  int followersLen = 0;
  int followingLen = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData()async{
    try{
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      var postSnap = await FirebaseFirestore.instance.collection('posts').where("uid",isEqualTo: widget.uid).get();


      setState((){
        userData = userSnap.data()!;
        postLen = postSnap.docs.length;
        followersLen = userSnap.data()!['followers'].length;
        followingLen = userSnap.data()!['following'].length;
        isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
        isLoaded = true;
      });
    }catch(err){
      showSnackBar(err.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(!isLoaded){
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: Text(userData['username']),
          centerTitle: false,
        ),
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(userData['photoUrl']),
                    radius: 40
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "posts"),
                              buildStatColumn(followersLen, "followers"),
                              buildStatColumn(followingLen, "following")
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid == widget.uid ? 
                              FollowButton(
                                  text: 'Edit Profile',
                                  textColor: primaryColor,
                                  backgroundColor: mobileBackgroundColor,
                                  borderColor: Colors.grey,
                                  function: () {}
                              ) : 
                              isFollowing ? 
                              FollowButton(
                                  text: 'Unfollow',
                                  textColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  borderColor: Colors.grey,
                                  function: ()async{
                                    await FirestoreMethods().followUser(uid: widget.uid);
                                    setState((){
                                      isFollowing = false;
                                      followersLen -= 1;
                                    });
                                  }
                              ) :
                              FollowButton(
                                  text: 'Follow',
                                  textColor: Colors.white,
                                  backgroundColor: Colors.blueAccent,
                                  borderColor: Colors.blueAccent,
                                  function: () async{
                                    await FirestoreMethods().followUser(uid: widget.uid);
                                    setState((){
                                      isFollowing = true;
                                      followersLen += 1;
                                    });
                                  }
                              )
                            ]
                        )
                      ],
                    ),
                ),
              ]
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 15),
                child: Text(userData['username'],style: const TextStyle(fontWeight: FontWeight.bold))
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 1),
                child: Text(userData['bio'])
              )
            ]),
          ),
          const Divider(),
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('posts').where("uid", isEqualTo: widget.uid).get(),
            builder: (context,AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,crossAxisSpacing: 5,mainAxisSpacing: 1.5,childAspectRatio: 1),
                itemBuilder: (context,index){
                  DocumentSnapshot snap = snapshot.data!.docs[index];

                  return Container(
                    child: Image(
                      image: NetworkImage(snap['postUrl']),
                      fit: BoxFit.cover
                    )
                  );
                }
              );
            },
          )
        ]));
  }

  Column buildStatColumn(int num, String label) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(num.toString(),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
              margin: const EdgeInsets.only(top: 4),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey)))
        ]);
  }
}
