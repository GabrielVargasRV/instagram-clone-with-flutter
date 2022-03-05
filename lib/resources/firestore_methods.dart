import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insta/models/post.dart';
import 'package:insta/resources/storage_methods.dart';
import 'package:insta/utils/utils.dart';
import 'package:uuid/uuid.dart';


class FirestoreMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  //upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profileImage
  )async{
    String res = "some error occurred";
    try{
      String photoUrl = await StorageMethods().uploadImageToStorage('posts',file,true);

      String postId = const Uuid().v1();

      Post post = Post(
        uid: uid,
        description: description,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: []
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());

    res = "success";
    }catch(err){
      res = err.toString();
    }
    return res;
  }


  Future<void> likePost({required String postId,required String uid,required List likes})async{
    try{
      if(likes.contains(uid)){
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      }else{
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    }catch(err){
      print(err.toString());
    }
  }

  Future<void> postComment({
  required String postId,
  required String text,
  required String uid,
  required String name,
  required String profilePhoto
  })async{
    try{
      if(text.isNotEmpty){
        String commentId = const Uuid().v1();
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePhoto': profilePhoto,
          'text': text,
          'username': name,
          'uid': uid,
          'commentId': commentId,
          'datePublished': DateTime.now()
        });
      }
    }catch(err){
      print(err.toString());
    }
  }

  Future<void> deletePost({required String postId})async{
    try{
      _firestore.collection('posts').doc(postId).delete();
    }catch(err){
      print(err.toString());
    }
  }

  Future<void> followUser({
    required String uid
  })async{
    try{
      DocumentSnapshot snap = await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      List following = (snap.data()! as dynamic)['following'];
      if(following.contains(uid)){
        await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
          'following': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }else{
        await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
          'following': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      }
    }catch(err){ 
      print(err.toString());
    }
  }
}