import 'dart:async';
import 'dart:convert';

import 'package:app/constants/strings.dart';
import 'package:app/models/message_model.dart';
import 'package:app/providers/database_provider.dart';
import 'package:app/screens/loading_screen.dart';
import 'package:app/utils/date_time_format.dart';
import 'package:app/utils/info_alert_dialog.dart';
import 'package:app/utils/toast.dart';
import 'package:app/widgets/horizontal_space.dart';
import 'package:app/widgets/vertical_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChatSupportScreen extends StatefulWidget {
  const ChatSupportScreen({Key? key}) : super(key: key);

  @override
  _ChatSupportScreenState createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isMessagesLoaded = false;
  List<MessageModel> messages = [];
  StreamSubscription<http.StreamedResponse>? _messagesSubscription;
  StreamSubscription<List<int>>? _messagesSubscription1;

  Future<void> sendMessage() async {
    try {
      if (_textController.text
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .isEmpty) {
       showSnackBar(context, 'empty');
        return;
      }
      MessageModel message = MessageModel(
          senderIsUser: true,
          body: _textController.text,
          date: {".sv": "timestamp"});
      await Provider.of<DatabaseProvider>(context, listen: false)
          .sendMessage(message.toMap());
      _textController.clear();
    } catch (error) {
      print(error.toString());
      showInfoAlertDialog(context, strings['unknown_error']!, true);
    }
  }

  Future<void> getMessages() async {
    try {
      final db = Provider.of<DatabaseProvider>(context, listen: false);
      var request = http.Request(
          "GET", Uri.parse(db.databaseApi('chats/${db.uId}/messages')));
      //request.headers["Cache-Control"] = "no-cache";
      request.headers["Accept"] = "text/event-stream";
      final Future<http.StreamedResponse> res = http.Client().send(request);

      _messagesSubscription = res.asStream().listen((event) {
        print(event.statusCode);
        _messagesSubscription1 = event.stream.listen((value) {
          print(utf8.decode(value));
          if (!utf8.decode(value).contains('null')) {
            final resData = json.decode(utf8.decode(value.sublist(17)));
            if (resData['path'].toString().length > 2) {
              messages.insert(
                  0,
                  MessageModel.fromJson(
                      Map<String, dynamic>.from(resData['data'])));
            } else {
              resData['data'].values.forEach((e) {
                print(e);
                messages.insert(
                    0, MessageModel.fromJson(Map<String, dynamic>.from(e)));
              });
            }
            //messages.sort((a, b) => b.date!.toString().compareTo(a.date!.toString()));
            setState(() {});
          }
        });
      });
      db.setMessagesUserUnreadCount();
    } catch (e) {
      print('getMessages' + e.toString());
    }
    setState(() {
      _isMessagesLoaded = true;
    });
  }

  @override
  void initState() {
    getMessages();
    super.initState();
  }

  @override
  void dispose() {
    if (_messagesSubscription != null) {
      _messagesSubscription!.cancel();
    }
    if (_messagesSubscription1 != null) {
      _messagesSubscription1!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: _isMessagesLoaded
          ? Container(
              alignment: Alignment.topCenter,
              width: size.width,
              height: size.height * .8,
              //padding: EdgeInsets.only(bottom: -5.1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        margin:
                            EdgeInsets.symmetric(horizontal: size.width * .02),
                        child: ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: messages.length,
                            itemBuilder: (BuildContext ctx, int i) {
                              return Container(
                                alignment: messages[i].senderIsUser!
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * .01,
                                  vertical: size.height * .01,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: size.width * .6,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.all(size.width * .02),
                                      decoration: BoxDecoration(
                                          color: messages[i].senderIsUser!
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        messages[i].body!,
                                        style: TextStyle(
                                          color: Colors.white,
                                            fontSize: size.width * .04),
                                      ),
                                    ),
                                    VerticalSpace(
                                        size: size, percentage: 0.005),
                                    Container(
                                      width: size.width * .6,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * .03,
                                      ),
                                      alignment: messages[i].senderIsUser!
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Text(
                                        formatDateTime(messages[i].date!),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: size.width * .03),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: size.width * .02),
                    height: size.height * .1,
                    width: size.width,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: size.width * .8,
                          height: size.height * .08,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(20)),
                          child: TextField(
                            controller: _textController,
                            minLines: 1,
                            maxLines: null,
                            textInputAction: TextInputAction.newline,
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.multiline,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.height * .02),
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.all(size.width * .02),
                                border: InputBorder.none,
                                hintText: strings["message_hint"]),
                          ),
                        ),
                       // HorizontalSpace(size: size, percentage: .01),
                        InkWell(
                          onTap: () => sendMessage(),
                          child: Container(
                            width: size.width * .13,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: size.width * 0.06,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          : const LoadingScreen(),
    );
  }
}
