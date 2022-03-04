import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:insta/models/user.dart';
import 'package:insta/providers/user_provider.dart';
import 'package:insta/resources/firestore_methods.dart';
import 'package:insta/screens/comments_screen.dart';
import 'package:insta/utils/colors.dart';
import 'package:insta/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {

  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color:mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16).copyWith(right:0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.snap['profileImage']),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(widget.snap['username'],style: const TextStyle(fontWeight: FontWeight.bold))
                      ]
                    )
                  )
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: (){
                    showDialog(context: context, builder: (context) => Dialog(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shrinkWrap: true,
                        children: [
                          widget.snap['uid'] == user.uid ? "Delete" : "Report"
                        ].map((e) => InkWell(
                          onTap:()async{
                            if(widget.snap['uid'] == user.uid){
                              FirestoreMethods().deletePost(postId: widget.snap['postId']);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Text(e)
                          )
                        )).toList()
                      )
                    ));
                  },
                )
              ]
            ),
          ),
          
          GestureDetector(
            onDoubleTap:()async{
              await FirestoreMethods().likePost(
                postId: widget.snap['postId'],
                uid: user.uid,
                likes: widget.snap['likes']
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'],
                    fit: BoxFit.cover
                  )
                ),
                AnimatedOpacity(
                  opacity: isLikeAnimating? 1: 0,
                  duration: const Duration(milliseconds: 200),
                  child: LikeAnimation(
                    child: const Icon(Icons.favorite,color: Colors.white, size: 100),
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: (){
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                ),
              ]
            ),
          ),

          //LIKE COMMENT SECTION
          Row(
            children:[
              LikeAnimation(
                child: IconButton(
                  icon: widget.snap['likes'].contains(user.uid) ? const Icon(Icons.favorite,color: Colors.red) : const Icon(Icons.favorite_outline),
                  onPressed: ()async {
                    await FirestoreMethods().likePost(
                      postId: widget.snap['postId'],
                      uid: user.uid,
                      likes: widget.snap['likes']
                    );
                  }
                ),
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
              ),
              IconButton(
                icon: const Icon(Icons.comment_outlined,color: primaryColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommentsScreen(
                    snap: widget.snap
                  )));
                }
              ),
              IconButton(
                icon: const Icon(Icons.send,color: primaryColor),
                onPressed: () {}
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed:(){}
                  )
                )
              )
            ]
          ),

          // Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(fontWeight: FontWeight.w800),
                  child: Text(widget.snap['likes'].length.toString() + " likes", style: Theme.of(context).textTheme.bodyText2)
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style:const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        TextSpan(
                          text:" " + widget.snap['description'],
                        )
                      ]
                    )
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommentsScreen(
                      snap: widget.snap
                    )));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text("View all comments",style: TextStyle(fontSize: 16,color: secondaryColor))
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()) ,style: const TextStyle(fontSize: 16,color: secondaryColor))
                ),
              ]
            )
          ),

        ]
      )
    );
  }
}