import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/utils/colors.dart';
import 'package:insta/utils/utils.dart';
import 'package:insta/models/user.dart';
import 'package:insta/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController  _descriptionController = TextEditingController();

  _selectImage(BuildContext context) async {
    return showDialog(context: context, builder: (context) {
      return SimpleDialog(
        title: const Text("Create a post"),
        children:[
          SimpleDialogOption(
            padding: const EdgeInsets.all(20.0),
            child: const Text("Take a photo"),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file = await pickImage(
                ImageSource.camera
              );
              setState((){
                _file = file;
              });
            }
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20.0),
            child: const Text("Choose from gallery"),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file = await pickImage(
                ImageSource.gallery
              );
              setState((){
                _file = file;
              });
            }
          ),
          //cancel
          SimpleDialogOption(
            padding: const EdgeInsets.all(20.0),
            child: const Text("Cancel"),
            onPressed: (){
              Navigator.of(context).pop();
            }
          ),
        ]
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return _file == null ? 
    Center(
      child: IconButton(
        icon: const Icon(Icons.upload),
        onPressed: () {
          _selectImage(context);
        }
      )
    ) : 
    Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:(){}
        ),
        title: const Text('Post to'),
        centerTitle: false,
        actions:[
          TextButton(
            onPressed: (){},
            child: const Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16.0
              )
            )
          )
        ]
      ),
      body: Column(
        children:[ 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl)
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.45,
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Write a caption..."
                  ),
                  maxLines: 8,
                )
              ),
              SizedBox(
                height: 45,
                width: 45,
                child: AspectRatio(
                  aspectRatio: 487/451,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(_file!),
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter,
                      )
                    ),
                  )
                )
              ),
              const Divider()
            ]
          )
        ]
      ),
    );
  }
}