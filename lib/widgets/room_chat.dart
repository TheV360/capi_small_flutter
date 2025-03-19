import 'package:capi_small_mvp/widgets/room_data.dart';
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
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final model =
        context.read<RoomsData>().getRoomById(widget.room.id)!.messages;
    return ListenableBuilder(
      listenable: model,
      builder: (context, child) => ListView.builder(
        reverse: false,
        controller: scrollController,
        itemCount: model.messages.length,
        itemBuilder: (context, index) => (index < model.messages.length)
            ? ChatMessage(
                key: ValueKey(model.messages[index].messageId),
                inner: model.messages[index],
              )
            : null,
      ),
    );
  }
}
