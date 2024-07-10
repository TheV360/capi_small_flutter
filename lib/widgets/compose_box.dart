import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComposeBox extends StatefulWidget {
  const ComposeBox({super.key});

  @override
  State<ComposeBox> createState() => _ComposeBoxState();
}

class _ComposeBoxState extends State<ComposeBox> {
  TextEditingController textEditingController = TextEditingController();
  bool sending = false; // sorry lol

  Future<void> _sendMessage() async {
    final client = Provider.of<CapiClient>(context, listen: false);
    final room = Provider.of<RoomSelection>(context, listen: false);

    final message = textEditingController.text;

    try {
      setState(() {
        sending = true;
        textEditingController.clear();
      });
      await client.postInChat(
        roomId: room.selectedRoom!.id,
        message: message,
      );
    } catch (e) {
      textEditingController.text = message;
    }
    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CapiClient, RoomSelection>(
      builder: (context, client, room, _) => Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              enabled: !sending,
              maxLines: 3,
              decoration: const InputDecoration(filled: true),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
          )
        ]),
      ),
    );
  }
}
