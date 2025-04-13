import 'package:flutter/foundation.dart';

import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/network/capi_client.dart';

class RoomMessagesModel with ChangeNotifier {
  // new items should be sorted into the array, lowest mid to highest.
  // is there a good "mostly sorted" algorithm
  //
  // algorithm that checks if mid > last mid, otherwise bin search and insert
  final List<CapiSmall> _messages = [];
  List<CapiSmall> get messages => _messages;

  // int? get lastMessageId => _messages.reversed
  //     .where((msg) => msg.messageId != null)
  //     .firstOrNull
  //     ?.messageId;

  void addMessage(CapiSmall incoming) {
    if (incoming.messageId == null) return;

    final insertIndex = findIndexForInsert(incoming.messageId!);
    if (insertIndex == _messages.length) {
      if (incoming.state.deleted) return;
      _messages.add(incoming);
    } else {
      final message = _messages[insertIndex];
      if (message.messageId! == incoming.messageId!) {
        if (incoming.state.deleted) {
          // not necessarily needed
          _messages.removeAt(insertIndex);
        } else if (incoming.state.edited) {
          // handle edits
          _messages[insertIndex] = incoming;
        } else {
          print("the dupe message warning!!! aaah!");
        }
      } else {
        _messages.insert(insertIndex, incoming);
      }
    }
    notifyListeners();
  }

  void removeMessage(CapiMessageId messageId) {
    final oldLength = _messages.length;
    _messages.removeWhere((m) => m.messageId == messageId);
    final newLength = _messages.length;
    if (newLength != oldLength) notifyListeners();
  }

  /// Returns the index where you should insert, if this is a new message.
  /// May return an index in [0, length], so don't just `messages[index]` it.
  int findIndexForInsert(CapiMessageId messageId) {
    if (_messages.isEmpty) return 0;

    assert(areMessagesSorted());

    if (_messages.lastOrNull case CapiSmall last) {
      if (messageId > last.messageId!) return _messages.length;
      if (messageId == last.messageId!) return _messages.length - 1;
    }

    if (messageId <= _messages.firstOrNull!.messageId!) return 0;

    int bottomIndex = 0, topIndex = _messages.length;
    while (bottomIndex < topIndex) {
      // it's binary search.
      final int middleIndex = (bottomIndex + topIndex) >> 1;
      final middleId = _messages[middleIndex].messageId!;
      if (messageId > middleId) {
        bottomIndex = middleIndex + 1;
      } else if (messageId < middleId) {
        topIndex = middleIndex - 1;
      } else {
        return middleIndex;
      }
    }

    return _messages.length;
  }

  // TODO: remove this, use "specialized" Message model type with un-nullable messageId field.
  bool areMessagesValid() => _messages.every((m) => m.messageId != null);

  bool areMessagesSorted() {
    if (!areMessagesValid()) return false;
    for (var left = 0; left < _messages.length - 1; left++) {
      if (_messages[left].messageId! > _messages[left + 1].messageId!) {
        return false;
      }
    }
    return true;
  }
}

class RoomUserListModel with ChangeNotifier {
  final Set<String> _users = {};
  Set<String> get users => _users;

  static Set<String> parseUserList(String s) => {...s.split(', ')};

  void updateFromString(String incoming) => update(parseUserList(incoming));

  void update(Set<String> incoming) {
    if (_users == incoming) return;
    _users.clear();
    _users.addAll(incoming);
    notifyListeners();
  }

  List<String> toList() => _users.toList()..sort();
}

/// see [package:capi_small_mvp/widgets/room_selector.dart:7]
class RoomData with ChangeNotifier {
  // TODO: turn this into a CapiSmall-like struct that only stores the fields we want
  // alternatively, we can always just use the "effective latest message" and show it to the user.
  CapiSmall info;

  final RoomMessagesModel messages = RoomMessagesModel();
  final RoomUserListModel userList = RoomUserListModel();

  RoomData(this.info);

  void updateInfo(CapiSmall newInfo) {
    info = newInfo;
    notifyListeners();
  }
}

class RoomsData with ChangeNotifier {
  final RoomUserListModel globalUserList = RoomUserListModel();
  final Map<CapiPageId, RoomData> _rooms = {};

  RoomData? getRoomById(CapiPageId pageId) => _rooms[pageId];
  get roomIdsList => _rooms.keys.toList();

  RoomData recognizeRoom(CapiSmall roomEntry) {
    final existingRoom = _rooms[roomEntry.pageId!];
    if (existingRoom == null) {
      final newRoom = RoomData(roomEntry);
      _rooms[roomEntry.pageId!] = newRoom;
      notifyListeners(); // why?
      return newRoom;
    } else {
      existingRoom.updateInfo(roomEntry);
      return existingRoom;
    }
  }

  void doCommand(CapiSmall small) {
    switch (small.pageId) {
      case null:
        return;
      case 0:
        switch (small.module) {
          case 'userlist':
            globalUserList.updateFromString(small.message);
        }
      default:
        RoomData roomData = recognizeRoom(small);
        switch (small.module) {
          case 'eventId':
            print(small.message);
          case 'userlist':
            print(small.message);
            roomData.userList.updateFromString(small.message);
          default:
            roomData.messages.addMessage(small);
        }
    }
  }

  void listen(CapiClient client) {
    print("waking up!");

    // TODO: replace tempRoomId
    final roomIds = [if (client.tempRoomId != null) client.tempRoomId!];
    final commandStream = client.fetchAndStreamChat(roomIds: roomIds);
    commandStream.listen(
      (d) => doCommand(d),
      onError: (e) => print(e),
    );
  }
}
