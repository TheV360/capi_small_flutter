import 'dart:math';

import 'package:capi_small_mvp/widgets/divider_text.dart';
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

  final UniqueKey _center = UniqueKey();

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
    if (!_scrollController.hasClients) return print('no clients?');
    _scrollController.jumpTo(
      _animationController.value * _scrollController.position.maxScrollExtent,
    );
  }

  /// "Utilizes the link between the `AnimationController` and `ScrollController`
  /// to start at the user's current scroll position and fling them to the bottom.
  ///
  /// ("bottom" is the max scroll extent seen in [_linkAnimationToScroll])"
  void scrollToEnd({ListEnd end = ListEnd.bottom}) {
    if (!_scrollController.hasClients) return print('no clients? 2');
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
    return CustomScrollView(
      controller: _scrollController,
      scrollDirection: Axis.vertical,
      center: _center,
      anchor: 1.0,
      // reverse: true,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {},
                child: const Text('Load older messages'),
              ),
            ),
          ),
        ),
        ListenableBuilder(
          listenable: model,
          builder: (context, _) => buildMessageList(context),
        ),
        SliverToBoxAdapter(
          key: _center,
          child: const DividerText(label: "something"),
        ),
      ],
    );
  }

  Widget buildMessageList(BuildContext context) {
    return SliverList.builder(
      // TODO: convert this to use slivers, and add a button for loading more messages from a pivot point.
      // see example in https://api.flutter.dev/flutter/widgets/ScrollView/anchor.html
      itemCount: model.messages.length,
      itemBuilder: (context, index) {
        final revIndex = (model.messages.length - 1) - index;
        final message = model.messages.elementAtOrNull(revIndex);
        if (message == null) {
          print("wtf? $index of [0,${model.messages.length})");
          return null;
        }
        return ChatMessage(
          key: ValueKey('message${message.messageId}'),
          inner: message,
          onTap: () => showMessageInfoDialog(context, message),
        );
      },
    );
  }

  static void showMessageInfoDialog(BuildContext context, CapiSmall message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('All Good'),
          )
        ],
      ),
    );
  }
}
