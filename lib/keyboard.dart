import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard/safe_text_input.dart';

class SafeKeyboard extends StatefulWidget {
  TextInputClientHandler clientHandler;

  SafeKeyboard(this.clientHandler);

  @override
  _SafeKeyboardState createState() => new _SafeKeyboardState();
}

class _SafeKeyboardState extends State<SafeKeyboard> {
  String resultText = '';

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 200.0,
      child: new GridView.count(
        crossAxisCount: 3,
        children: <Widget>[
          new GestureDetector(
            onTap: () async {
              updateText('1');
            },
            child: new Center(child: new Text('1')),
          ),
          new GestureDetector(
            onTap: () async {
              updateText('2');
            },
            child: new Center(child: new Text('1')),
          ),
          new GestureDetector(
            onTap: () async {
              updateText('3');
            },
            child: new Center(child: new Text('1')),
          ),
          new GestureDetector(
            onTap: () async {
              updateText('4');
            },
            child: new Center(child: new Text('1')),
          ),
          new GestureDetector(
            onTap: () async {
              updateText('5');
            },
            child: new Center(child: new Text('1')),
          ),
          new GestureDetector(
            onTap: () async {
              updateText('6');
            },
            child: new Center(child: new Text('1')),
          ),
        ],
      ),
    );
  }

  updateText(String text) {
    resultText = resultText + text;
    widget.clientHandler.handleTextInputInvocation(
        new MethodCall('TextInputClient.updateEditingState', [
      0,
      {
        "composingExtent": -1,
        "text": resultText,
        "composingBase": -1,
        "selectionBase": resultText.length,
        "selectionExtent": resultText.length
      }
    ]));
  }
}
