import 'dart:math';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/model/room.dart';
import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';
import 'package:capi_small_mvp/widgets/chat_message.dart';
import 'package:capi_small_mvp/widgets/room_data.dart';

enum ListEnd { top, bottom }

class RoomChat extends StatefulWidget {
  final Room room;

  const RoomChat({super.key, required this.room});

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat>
    with SingleTickerProviderStateMixin {
  // dear god THANK YOU to https://stackoverflow.com/a/77175903/8659088
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1),
  );
  final ScrollController _scrollController = ScrollController();

  late final RoomMessagesModel model;

  @override
  void initState() {
    super.initState();
    _animationController.addListener(_linkAnimationToScroll);

    model = context.read<RoomsData>().getRoomById(widget.room.id)!.messages;
    model.addListener(scrollToEnd);

    // context.read<CapiClient>().fetchChat(roomIds: [widget.room.id]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// "Joins the `AnimationController` to the `ScrollController`, providing ample
  /// time for the lazy list to render its contents while scrolling to the bottom."
  void _linkAnimationToScroll() {
    _scrollController.jumpTo(
      _animationController.value * _scrollController.position.maxScrollExtent,
    );
  }

  /// "Utilizes the link between the `AnimationController` and `ScrollController`
  /// to start at the user's current scroll position and fling them to the bottom.
  ///
  /// ("bottom" is the max scroll extent seen in [_linkAnimationToScroll])"
  void scrollToEnd({ListEnd end = ListEnd.bottom}) {
    _animationController.value = max(0, _scrollController.position.pixels) /
        max(1, _scrollController.position.maxScrollExtent);
    _animationController.fling(
        velocity: switch (end) {
      ListEnd.top => -1,
      ListEnd.bottom => 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, child) => ListView.builder(
        // reverse: true,
        controller: _scrollController,
        itemCount: model.messages.length,
        itemBuilder: (context, index) => (index < model.messages.length)
            ? ChatMessage(
                key: ValueKey(model
                    .messages[/*(model.messages.length - 1) - */ index]
                    .messageId),
                inner: model.messages[/*(model.messages.length - 1) - */ index],
                // onTap: () => scrollToEnd(end: ListEnd.bottom)
                onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                            content: Text(model.messages[index].toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('All Good'),
                              )
                            ])),
              )
            : null,
      ),
    );
  }
}
