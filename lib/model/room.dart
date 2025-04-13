import 'package:flutter/material.dart';

import 'package:capi_small_mvp/model/capi_small.dart';

class Room {
  final CapiPageId id;
  final String name;
  final bool isPublic;
  final bool isReadOnly;

  const Room({
    required this.id,
    required this.name,
    required this.isPublic,
    required this.isReadOnly,
  });

  factory Room.fromSmall(CapiSmall small) => Room(
        id: small.pageId!,
        name: small.pageName,
        isPublic: small.state.publiclyViewable,
        isReadOnly: !small.state.userCanPostInRoom,
      );

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
