import 'dart:io';
import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/theme.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class Gchat extends StatefulWidget {
  final String chatRoomId;
  final List users;

  Gchat({this.chatRoomId, this.users});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Gchat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  File _imageFile;
  String downloadUrl;
  final picker = ImagePicker();

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future selectImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_imageFile.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then((value) => print("Done: $value"));
    downloadUrl = await taskSnapshot.ref.getDownloadURL();
    print(downloadUrl);
    addMessage();
    setState(() {
      _imageFile = null;
    });
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].data["sendBy"],
                    userName: snapshot.data.documents[index].data["message"],
                  );
                })
            : Container();
      },
    );
  }

  addMessage() {
    bool isImage = false;
    String message;
    print("notnull0");
    if (messageEditingController.text.isNotEmpty || downloadUrl != null) {
      print("not null1");
      if (downloadUrl != null) {
        message = downloadUrl;
        isImage = true;
        print("not null");
      } else {
        message = messageEditingController.text;
      }
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": message,
        'time': DateTime.now().millisecondsSinceEpoch,
        'isImage': isImage,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatRoomId),
        centerTitle: true,
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                color: Color(0x54FFFFFF),
                child: Row(
                  children: [
                    Expanded(
                        child: _imageFile != null
                            ? Image.file(_imageFile)
                            : TextField(
                                controller: messageEditingController,
                                style: simpleTextStyle(),
                                decoration: InputDecoration(
                                    hintText: "Aa",
                                    hintStyle: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    border: InputBorder.none),
                              )),
                    SizedBox(
                      width: 16,
                    ),
                    /* (imageUrl != null)
                        ? Image.network(imageUrl)
                        : Placeholder(
                            fallbackHeight: 200.0,
                            fallbackWidth: double.infinity), */
                    GestureDetector(
                      onTap: pickImage,
                      child: Icon(Icons.camera_alt),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: selectImage,
                      child: Icon(Icons.photo_album),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_imageFile != null) {
                          uploadImageToFirebase(context);

                          print('test');
                        }
                        addMessage();
                        print('test2');
                      },
                      child: Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String userName;

  MessageTile(
      {@required this.message,
      @required this.sendByMe,
      @required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: CustomTheme.colorAccent,
                borderRadius: BorderRadius.circular(30)),
            child: Text(userName.substring(0, 1),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
          ),
          Container(
            margin: sendByMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: sendByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23))
                  : BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23)),
              color: Color.fromRGBO(67, 204, 71, 8),
            ),
            child: Text(message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
          ),
        ],
      ),
    );
  }
}
