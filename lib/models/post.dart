

import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String uid;
  final String profileImage;
  final String username;
  final String description;
  final String postId;
  final datePublished;
  final String postUrl;
  final likes;

  const Post({
    required this.uid, 
    required this.profileImage,
    required this.username,
    required this.description,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.likes
  });

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "profilemage": profileImage,
    "username": username,
    "description": description,
    "postId": postId,
    "datePublished": datePublished,
    "postUrl": postUrl,
    "likes": likes
  };

  static Post fromSnap(DocumentSnapshot snap){
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      uid: snapshot['uid'],
      profileImage: snapshot['profileImage'],
      username: snapshot['username'],
      description: snapshot['description'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'],
      likes: snapshot['likse']
    );
  }

}