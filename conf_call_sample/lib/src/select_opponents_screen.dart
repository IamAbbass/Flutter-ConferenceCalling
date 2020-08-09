import 'package:conf_call_sample/src/utils/call_manager.dart';
import 'package:conf_call_sample/src/utils/video_config.dart';
import 'package:flutter/material.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';

import 'call_screen.dart';
import 'utils/configs.dart' as utils;

class SelectDialogScreen extends StatelessWidget {
  final CubeUser currentUser;
  SelectDialogScreen(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Logged in as ${currentUser.fullName}',
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => _logOut(context),
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: BodyLayout(currentUser),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return Future.value(false);
  }

  _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want logout current user"),
          actions: <Widget>[
            FlatButton(
              child: Text("CANCEL"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                signOut().then(
                  (voidValue) {
                    Navigator.pop(context); // cancel current Dialog
                    _navigateToLoginScreen(context);
                  },
                ).catchError(
                  (onError) {
                    Navigator.pop(context); // cancel current Dialog
                    _navigateToLoginScreen(context);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToLoginScreen(BuildContext context) {
    Navigator.pop(context);
  }
}

class BodyLayout extends StatefulWidget {
  final CubeUser currentUser;
  BodyLayout(this.currentUser);
  @override
  State<StatefulWidget> createState() {
    return _BodyLayoutState(currentUser);
  }
}

class _BodyLayoutState extends State<BodyLayout> {
  Set<int> _selectedUsers = {};
  final CubeUser currentUser;
  String joinRoomId;
  CallManager _callManager;
  ConferenceClient _callClient;
  ConferenceSession _currentCall;

  _BodyLayoutState(this.currentUser);

  TextEditingController _c = new TextEditingController();
  String _text = "";
  

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: RaisedButton(
                color: Colors.white,
                padding: EdgeInsets.all(24),                
                child: Text("Start Conference Call", style: TextStyle(fontSize: 18, color: Colors.black),),
                onPressed: () => _startCall(joinRoomId),
              ),
            ),
            Text("Your Room ID: ${joinRoomId}", style: TextStyle(fontSize: 20)),
            SizedBox(height:24),
            Center(
              child: RaisedButton(
                color: Colors.white,
                padding: EdgeInsets.all(24),  
                child: Text("Join Conference Call", style: TextStyle(fontSize: 18, color: Colors.black),),
                onPressed: (){
                 showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Join"),
                      content:
                          new TextField(
                            autofocus: true,
                            decoration: new InputDecoration(hintText: "Room ID"),
                            keyboardType: TextInputType.number,
                            controller: _c,
                        ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("CANCEL"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text("JOIN"),
                          onPressed: () async {
                            Navigator.pop(context);

                            if(_c.text == "1500908" || 
                            _c.text == "1500909" || 
                            _c.text == "1500911" ||
                            _c.text == "1500912" || 
                            _c.text == "1500913" || 
                            _c.text == "1500914" || 
                            _c.text == "1500915" || 
                            _c.text == "1500916" || 
                            _c.text == "1500917" || 
                            _c.text == "1500918" || 
                            _c.text == "1758581" || 
                            _c.text == "1758587"){
                              //_currentCall.joinDialog(_c.text, (publishers){
                                _startCall(_c.text);
                              //});                              
                            }else{
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Invalid Room ID"),
                                    content: Text("The Room ID you entered is invalid!"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }                            
                          },
                        ),
                      ],
                    );
                  },
                ); 
                },
              ),
            ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    _initConferenceConfig();
    _initCalls();
    joinRoomId = currentUser.id.toString();
    print("joinRoomId: ${joinRoomId}");
  }

  void _initCalls() {
    _callClient = ConferenceClient.instance;
    _callManager = CallManager.instance;
    _callManager.onReceiveNewCall = (roomId, participantIds) {
      _showIncomingCallScreen(roomId, participantIds);
    };
    _callManager.onCloseCall = () {
        _currentCall = null;
    };
  }

  void _startCall(String roomId) async {
    
    List<int> opponents = new List<int>();

    CubeUser currentUser = CubeChatConnection.instance.currentUser;
    final users = utils.users.where((user) => user.id != currentUser.id).toList();
    for(var i = 0; i < users.length; i++){
        opponents.add(users[i].id);
    }

    _currentCall = await _callClient.createCallSession(currentUser.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationCallScreen(_currentCall, roomId, opponents.toList(), false),
      ),
    );
  }

  void _showIncomingCallScreen(String roomId, List<int> participantIds) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(roomId, participantIds),
      ),
    );
  }

  void _initConferenceConfig() {
    ConferenceConfig.instance.url = utils.SERVER_ENDPOINT;
  }
}
