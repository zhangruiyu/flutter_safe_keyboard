import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard/safe_text_input.dart';

class SafeKeyboard extends StatefulWidget {
  final TextInputClientHandler clientHandler;
  final Function closeInputConnectionIfNeeded;
  final int _id;

  SafeKeyboard(
    this.clientHandler,
    this.closeInputConnectionIfNeeded,
    GlobalKey<SafeKeyboardState> keyboardStateKey,
    this._id,
  ) : super(key: keyboardStateKey);

  @override
  SafeKeyboardState createState() => new SafeKeyboardState();
}

TextEditingValue resultValue = new TextEditingValue();

class SafeKeyboardState extends State<SafeKeyboard> {
  double gridWidth;
  double gridHeight;
  double actionButtonWidth = 100.0;

  @override
  void initState() {
    super.initState();
  }

  Map<String, String> oneLineNumberKey = {
    '1': '1',
    '2': '2',
    '3': '3',
  };
  Map<String, String> twoLineNumberKey = {
    '4': '4',
    '5': '5',
    '6': '6',
  };
  Map<String, String> threeLineNumberKey = {'7': '7', '8': '8', '9': '9'};
  Map<String, String> fourLineNumberKey = {'00': '00', '0': '0', '^': '^'};

  @override
  void dispose() {
    widget.closeInputConnectionIfNeeded();
    super.dispose();
  }

  Widget buildNumberWidget(Map<String, String> lineNumberKey) {
    List<Widget> widgets = new List();

    lineNumberKey.forEach((String key, String value) {
      widgets.add(new InkWell(
        onTap: () {
          updateText(value);
        },
        child: new Container(
            decoration: new BoxDecoration(
                border: new Border.all(
              color: Colors.grey,
              width: 0.2,
            )),
            alignment: Alignment.center,
            width: gridWidth / 3,
            height: gridHeight,
            child: new Text(key)),
      ));
    });
    return new Row(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    gridWidth = MediaQuery.of(context).size.width - actionButtonWidth;
    gridHeight = gridWidth / 3 * 0.7;
    double gridTotalHeight = gridWidth / 3 * 0.7 * 4;
    return new SafeArea(
      child: new Container(
        height: gridTotalHeight,
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Container(
              width: gridWidth,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildNumberWidget(oneLineNumberKey),
                  buildNumberWidget(twoLineNumberKey),
                  buildNumberWidget(threeLineNumberKey),
                  buildNumberWidget(fourLineNumberKey),
                ],
              ),
            ),
            new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Container(
                  decoration: new BoxDecoration(
                      border: new Border.all(
                    color: Colors.grey,
                    width: 0.2,
                  )),
                  width: actionButtonWidth,
                  height: gridTotalHeight / 2,
                  child: new FlatButton(
                      child: new Icon(Icons.delete),
                      onPressed: () {
                        deleteText();
                      }),
                ),
                new Container(
                  color: const Color(0xffe71d36),
                  width: actionButtonWidth,
                  height: gridTotalHeight / 2,
                  child: new FlatButton(
                      textColor: Colors.white,
                      child: new Text(
                        '确认',
                        style: new TextStyle(fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.clientHandler.handleTextInputInvocation(
                            new MethodCall('TextInputClient.performAction',
                                [widget._id, 'TextInputAction.done']));
                      }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  updateText(String text) {
    if (text == '^') {
      Navigator.pop(context);
      return;
    }
    if (resultValue.selection.baseOffset == -1 ||
        resultValue.selection.baseOffset == resultValue.text.length) {
      String resultText = resultValue.text + text;
      resultValue = resultValue.copyWith(
          text: resultText,
          selection: new TextSelection(
            baseOffset: resultText.length,
            extentOffset: resultText.length,
          ));
    } else {
      print(resultValue.text.substring(0, resultValue.selection.baseOffset));
      String frontText =
          resultValue.text.substring(0, resultValue.selection.baseOffset) +
              text;
      String resultText = frontText +
          resultValue.text.substring(resultValue.selection.baseOffset);
      resultValue = resultValue.copyWith(
          text: resultText,
          selection: new TextSelection(
            baseOffset: frontText.length,
            extentOffset: frontText.length,
          ));
    }
    widget.clientHandler.handleTextInputInvocation(new MethodCall(
        'TextInputClient.updateEditingState',
        [widget._id, resultValue.toJSON()]));
  }

  deleteText() {
    if (resultValue.text?.isEmpty == true) {
      return;
    }
    if (resultValue.selection.baseOffset == -1 ||
        resultValue.selection.baseOffset == resultValue.text.length) {
      String resultText =
          resultValue.text.substring(0, resultValue.text.length - 1);
      resultValue = resultValue.copyWith(
          text: resultText,
          selection: new TextSelection(
            baseOffset: resultText.length,
            extentOffset: resultText.length,
          ));
    } else {
      String frontText =
          resultValue.text.substring(0, resultValue.selection.baseOffset - 1);
      String resultText = frontText +
          resultValue.text.substring(resultValue.selection.baseOffset);
      resultValue = resultValue.copyWith(
          text: resultText,
          selection: new TextSelection(
            baseOffset: frontText.length,
            extentOffset: frontText.length,
          ));
    }
    widget.clientHandler.handleTextInputInvocation(new MethodCall(
        'TextInputClient.updateEditingState',
        [widget._id, resultValue.toJSON()]));
  }

  void setEditingState(TextEditingValue value) {
    resultValue = value;
  }
}
