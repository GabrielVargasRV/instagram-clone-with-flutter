import 'package:flutter/material.dart';
import 'package:insta/screens/add_post_screen.dart';
import 'package:insta/screens/feed_screen.dart';

const webScreenSize = 600;

var homeScreenItems = [
  FeedScreen(),
  Text("search"),
  AddPostScreen(),
  Text("notifications"),
  Text("accound")
];
