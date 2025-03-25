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

  int? get lastMessageId => _messages.reversed
      .where((msg) => msg.messageId != null)
      .firstOrNull
      ?.messageId;

  void addMessage(CapiSmall incoming) {
    if (incoming.messageId == null) return;

    final msgId = incoming.messageId!;

    // final insertIndex = _messages
    //     .indexWhere((existing) => existing.messageId! > incoming.messageId!);
    final insertIndex = findMessageWithClosestId(msgId);
    if (insertIndex == null) {
      final lowBound = _messages.firstOrNull?.messageId ?? 0;
      final uppBound = _messages.lastOrNull?.messageId ?? 0;
      print("couldn't find best insert index"
          " for $msgId in ($lowBound, $uppBound)");
      _messages.add(incoming);
    } else {
      _messages.insert(insertIndex, incoming);
    }
    notifyListeners();
  }

  void removeMessage(CapiMessageId messageId) {
    final oldLength = _messages.length;
    _messages.removeWhere((m) => m.messageId == messageId);
    final newLength = _messages.length;
    if (newLength != oldLength) notifyListeners();
  }

  int? findMessageWithClosestId(int msgId) {
    int bottomIndex = 0, topIndex = _messages.length;
    assert(areMessagesSorted());
    while (bottomIndex < topIndex) {
      // it's binary search.
      final int midIndex = (bottomIndex + topIndex) >> 1;
      final midId = _messages[midIndex].messageId!;
      if (msgId > midId) {
        bottomIndex = midIndex + 1;
      } else if (msgId < midId) {
        topIndex = midIndex - 1;
      } else {
        return midIndex;
      }
    }
    return null;
  }

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
}

/// see [package:capi_small_mvp/widgets/room_selector.dart:7]
class RoomData {
  // TODO: turn this into a CapiSmall-like struct that only stores the fields we want
  // alternatively, we can always just use the "effective latest message" and show it to the user.
  CapiSmall info;

  final RoomMessagesModel messages = RoomMessagesModel();
  final RoomUserListModel userList = RoomUserListModel();

  RoomData(this.info);
}

class RoomsData with ChangeNotifier {
  late final Stream<CapiSmall> commandStream;
  final RoomUserListModel globalUserList = RoomUserListModel();
  final Map<CapiPageId, RoomData> _rooms = {};

  RoomData? getRoomById(CapiPageId pageId) => _rooms[pageId];

  RoomData recognizeRoom(CapiSmall roomEntry) {
    final existingRoom = _rooms[roomEntry.pageId!];
    if (existingRoom == null) {
      final newRoom = RoomData(roomEntry);
      _rooms[roomEntry.pageId!] = newRoom;
      notifyListeners();
      return newRoom;
    } else {
      existingRoom.info = roomEntry;
      notifyListeners();
      return existingRoom;
    }
  }

  Future<void> listen(CapiClient client) async {
    commandStream = client.streamChat(roomIds: [1]); // TODO!
    await for (final small in commandStream) {
      switch (small.pageId) {
        case null:
          continue;
        case 0:
          switch (small.module) {
            case 'userlist':
              globalUserList.updateFromString(small.message);
          }
        default:
          RoomData roomData = recognizeRoom(small);
          switch (small.module) {
            case '':
              roomData.messages.addMessage(small);
            case 'userlist':
              roomData.userList.updateFromString(small.message);
          }
      }
    }
  }
}
