import 'package:flutter/material.dart';

import 'package:capi_small_mvp/model/capi_small.dart';

class Room {
  final CapiSmall inner;

  CapiPageId get id => inner.pageId!;
  String get name => inner.pageName;
  bool get isPublic => inner.state.publiclyViewable;
  bool get isReadOnly => !inner.state.userCanPostInRoom;

  const Room(this.inner);

  Icon getRoomIcon() => switch ((isPublic, isReadOnly)) {
        (_, true) => const Icon(Icons.newspaper),
        (true, false) => const Icon(Icons.groups_2),
        (false, false) => const Icon(Icons.group),
      };
  String describeRoomType() => [
        isPublic ? 'Public' : 'Private',
        if (isReadOnly) 'Read-Only',
        'Room'
      ].join(' ');
}
