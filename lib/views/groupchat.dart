import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/chat.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class GroupMember {
  String userName;
  String userEmail;

  groupMember(userName, userEmail) {
    this.userName = userName;
    this.userEmail = userEmail;
  }
}

class _SearchState extends State<Group> {
  Map groupMembers = Map();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchEditingController = new TextEditingController();
  TextEditingController groupChatNameController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  String addToGC = 'Add To Group Chat';
  bool isLoading = false;
  bool haveUserSearched = false;
  String errorText;

  initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await databaseMethods
          .searchByName(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;
        print("$searchResultSnapshot");
        setState(() {
          isLoading = false;
          haveUserSearched = true;
          addToGC = "Add to Group Chat";
        });
      });
    }
  }

  Widget userList() {
    return haveUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.documents.length,
            itemBuilder: (context, index) {
              return userTile(
                searchResultSnapshot.documents[index].data["userName"],
                searchResultSnapshot.documents[index].data["userEmail"],
              );
            })
        : Container();
  }

  /// 1.create a chatroom, send user to the chatroom, other userdetails
  sendMessage(Map groupMembers) {
    var _list = groupMembers.values.toList();
    List<String> users = [Constants.myName];
    for (int i = 0; i < _list.length; i++) {
      users.add(_list[i]);
    }

    // String chatRoomId = getChatRoomId(Constants.myName, userName);
    String chatRoomId = groupChatNameController.text;

    Map<String, dynamic> chatRoom = {
      "users": users,
      "chatRoomId": chatRoomId,
    };

    databaseMethods.addChatRoom(chatRoom, chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chat(
                  userName: chatRoomId,
                  chatRoomId: chatRoomId,
                )));
  }

  Widget showAlert() {
    if (errorText != null)
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(Icons.error_outline),
            Expanded(
              child: Text(
                errorText,
                maxLines: 3,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  errorText = null;
                });
              },
            )
          ],
        ),
      );
    else {
      return Container();
    }
  }

  Widget userTile(String userName, String userEmail) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              Text(
                userEmail,
                style: TextStyle(color: Colors.black, fontSize: 16),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              groupMembers[groupMembers.length] = userName;
              for (int i = 0; i < groupMembers.length; i++)
                print(groupMembers[i]);
              setState(() {
                addToGC = 'Added';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: addToGC == 'Added'
                      ? Colors.grey
                      : Color.fromRGBO(67, 204, 71, 8),
                  borderRadius: BorderRadius.circular(24)),
              child: Text(
                addToGC,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat Creation'),
        centerTitle: true,
      ),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Column(children: [
              showAlert(),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Color(0x54FFFFFF),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: groupChatNameController,
                            style: simpleTextStyle(),
                            decoration: InputDecoration(
                                hintText: "Enter Group Name",
                                hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Color(0x54FFFFFF),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchEditingController,
                            style: simpleTextStyle(),
                            decoration: InputDecoration(
                                hintText: "Search username ...",
                                hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            initiateSearch();
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        const Color(0x36FFFFFF),
                                        const Color(0x0FFFFFFF)
                                      ],
                                      begin: FractionalOffset.topLeft,
                                      end: FractionalOffset.bottomRight),
                                  borderRadius: BorderRadius.circular(40)),
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.search)),
                        )
                      ],
                    ),
                  ),
                  userList(),
                ],
              ),
            ]),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          if (groupMembers.length < 1) {
            setState(() {
              errorText = 'You must add atleast 1 member';
            });
          } else if (groupChatNameController.text.isEmpty) {
            setState(() {
              errorText = 'Group Name must not be empty';
            });
          } else {
            setState(() {
              errorText = null;
            });
            sendMessage(groupMembers);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(24)),
          child: FittedBox(
            child: Row(
              children: [
                Icon(
                  Icons.group_add,
                  color: Colors.white,
                ),
                Text(
                  "Create Group Chat",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
