import 'dart:convert';

import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:flutter/material.dart';

const defaultIcon =
    'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAIAAAACDbGyAAAAIklEQVQI12P8//'
    '8/AxJgYmBgYGRkRJBo8gzI/P///6PLAwAuoA79WVXllAAAAABJRU5ErkJggg==';

class ChatMessage extends StatelessWidget {
  final CapiSmall inner;

  const ChatMessage({super.key, required this.inner});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.memory(
          base64Decode(defaultIcon),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
      title: Text(inner.message),
      subtitle: Text('${inner.userName} · ${inner.postedAt.toString()}'),
      onTap: () {},
    );
  }
}
