import 'package:capi_small_mvp/model/capi_small.dart';

// intended lifetime is only for as long as the chatroom is onscreen..
//
// maybe some global object will dispatch info to each room state object..
class CapiRoom {
  final List<String> users = [];

  // new items should be sorted into the array, lowest mid to highest.
  // is there a good "mostly sorted" algorithm
  //
  // algorithm that checks if mid > last mid, otherwise bin search and insert
  final List<CapiSmall> messages = [];
  // todo: make inaccessible so nobody can violate my "sorted" and "only messages" rules

  int? get lastMessageId => messages.reversed
      .where((msg) => msg.messageId != null)
      .firstOrNull
      ?.messageId;

  void addMessage(CapiSmall msg) {
    if (msg.messageId == null) return;
    final msgId = msg.messageId!;

    final shouldAppend = messages.isEmpty || lastMessageId! <= msgId;

    if (shouldAppend) {
      messages.add(msg);
    } else {
      final insertIndex = findMessageWithClosestId(msgId);
      if (insertIndex == null) {
        final lowBound = messages.first.messageId;
        final uppBound = messages.last.messageId;
        print("couldn't find best insert index"
            " for $msgId in ($lowBound, $uppBound)");
      }
      messages.insert(insertIndex ?? messages.length, msg);
    }
  }

  int? findMessageWithClosestId(int msgId) {
    int bottomIndex = 0, topIndex = messages.length;
    while (bottomIndex <= topIndex) {
      // it's binary search.
      int midIndex = (bottomIndex + topIndex) >> 1;
      final midId = messages[midIndex].messageId!;
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

  late final Stream<CapiSmall> stream;
}
