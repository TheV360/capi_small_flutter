import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';
import 'package:capi_small_mvp/widgets/chat_message.dart';

class RoomChat extends StatefulWidget {
  final Room room;

  const RoomChat({super.key, required this.room});

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  late final Stream<CapiSmall> chatStream;
  final List<CapiSmall> messages = [];
  final ScrollController scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chatStream = context.read<CapiClient>().streamChat(
      roomIds: [widget.room.id],
    ).where((event) => event.messageId != null);
    uiStuff();
  }

  Future<void> uiStuff() async {
    await for (final small in chatStream) {
      setState(() {
        messages.add(small);
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: false,
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) => (index < messages.length)
          ? ChatMessage(
              key: ValueKey(messages[index].messageId),
              inner: messages[index],
            )
          : null,
    );
  }
}
