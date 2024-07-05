import 'package:flutter/material.dart';

import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/widgets/chat_message.dart';

class RoomChat extends StatelessWidget {
  const RoomChat({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // TODO
      stream: null,
      builder: (context, snapshot) {
        return ListView(
          reverse: true,
          children: List.generate(30, (i) {
            final [msg] = CapiSmall.fromCsv(
                '''Home,braixen,"well, now i'm here $i",2024-06-30T22:41:01.245Z,,RP,1,2,1''');
            return ChatMessage(inner: msg);
          }),
        );
      },
    );
  }
}
