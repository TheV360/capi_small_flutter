import 'dart:convert';

import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:flutter/material.dart';

const defaultIcon =
    'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAIAAAACDbGyAAAAIklEQVQI12P8//'
    '8/AxJgYmBgYGRkRJBo8gzI/P///6PLAwAuoA79WVXllAAAAABJRU5ErkJggg==';

class ChatMessage extends StatelessWidget {
  final CapiSmall inner;

  final void Function()? onTap;

  const ChatMessage({super.key, required this.inner, this.onTap});

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
      title: inner.state.deleted ? null : Text(inner.message),
      subtitle: Text([
        if (inner.module != '') inner.module,
        if (inner.userId != null)
          inner.module == '' ? inner.userName : 'from ${inner.userName}',
        if (inner.postedAt != null)
          inner.postedAt!.toLocal().toString().split('.')[0],
        if (inner.state.edited) 'Edited',
        if (inner.state.deleted) 'Deleted',
        if (inner.state.userIsRecipient) 'Private',
      ].join(' · ')),
      onTap: onTap,
    );
  }
}
