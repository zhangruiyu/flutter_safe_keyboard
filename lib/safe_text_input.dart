// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard/keyboard.dart';

/// An interface for interacting with a text input control.
///
/// See also:
///
///  * [SafeTextInput.attach]
class SafeTextInputConnection {
  SafeTextInputConnection._(this._client)
      : assert(_client != null),
        _id = _nextId++;

  static int _nextId = 1;
  final int _id;

  final TextInputClient _client;

  /// Whether this connection is currently interacting with the text input control.
  bool get attached => _clientHandler._currentConnection == this;

  /// Requests that the text input control become visible.
  void show(BuildContext context) {
    assert(attached);
   showBottomSheet(context: context, builder: (context){
      return new SafeKeyboard(_clientHandler);
    });
//    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  /// Requests that the text input control change its internal state to match the given state.
  void setEditingState(TextEditingValue value) {
    assert(attached);
    SystemChannels.textInput.invokeMethod(
      'TextInput.setEditingState',
      value.toJSON(),
    );
  }

  /// Stop interacting with the text input control.
  ///
  /// After calling this method, the text input control might disappear if no
  /// other client attaches to it within this animation frame.
  void close(BuildContext context) {
    if (attached) {
      Navigator.pop(context);
//      SystemChannels.textInput.invokeMethod('TextInput.clearClient');
      _clientHandler
        .._currentConnection = null
        .._scheduleHide();
    }
    assert(!attached);
  }
}

TextInputAction _toTextInputAction(String action) {
  switch (action) {
    case 'TextInputAction.done':
      return TextInputAction.done;
    case 'TextInputAction.newline':
      return TextInputAction.newline;
  }
  throw new FlutterError('Unknown text input action: $action');
}

class TextInputClientHandler {
  TextInputClientHandler() {
    SystemChannels.textInput.setMethodCallHandler(handleTextInputInvocation);
  }

  SafeTextInputConnection _currentConnection;

  Future<dynamic> handleTextInputInvocation(MethodCall methodCall) async {
    if (_currentConnection == null) return;
    final String method = methodCall.method;
    final List<dynamic> args = methodCall.arguments;
    final int client = args[0];
    // The incoming message was for a different client.
//    if (client != _currentConnection._id) return;
    switch (method) {
      case 'TextInputClient.updateEditingState':
        _currentConnection._client
            .updateEditingValue(new TextEditingValue.fromJSON(args[1]));
        break;
      case 'TextInputClient.performAction':
        _currentConnection._client.performAction(_toTextInputAction(args[1]));
        break;
      default:
        throw new MissingPluginException();
    }
  }

  bool _hidePending = false;

  void _scheduleHide() {
    if (_hidePending) return;
    _hidePending = true;

    // Schedule a deferred task that hides the text input. If someone else
    // shows the keyboard during this update cycle, then the task will do
    // nothing.
    scheduleMicrotask(() {
      _hidePending = false;
      if (_currentConnection == null)
        SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }
}

final TextInputClientHandler _clientHandler = new TextInputClientHandler();

/// An interface to the system's text input control.
class SafeTextInput {
  SafeTextInput._();

  /// Begin interacting with the text input control.
  ///
  /// Calling this function helps multiple clients coordinate about which one is
  /// currently interacting with the text input control. The returned
  /// [TextInputConnection] provides an interface for actually interacting with
  /// the text input control.
  ///
  /// A client that no longer wishes to interact with the text input control
  /// should call [TextInputConnection.close] on the returned
  /// [TextInputConnection].
  static SafeTextInputConnection attach(
      TextInputClient client, TextInputConfiguration configuration) {
    assert(client != null);
    assert(configuration != null);
    final SafeTextInputConnection connection =
        new SafeTextInputConnection._(client);
    _clientHandler._currentConnection = connection;
    SystemChannels.textInput.invokeMethod(
      'TextInput.setClient',
      <dynamic>[connection._id, configuration.toJSON()],
    );
    return connection;
  }
}
