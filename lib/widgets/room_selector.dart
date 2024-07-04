import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:flutter/material.dart';

class RoomItem extends StatelessWidget {
  final int id;
  final String name;
  final bool isPublic;

  const RoomItem({
    super.key,
    required this.id,
    required this.name,
    required this.isPublic,
  });

  factory RoomItem.fromSmall(CapiSmall small) => RoomItem(
        id: small.pageId,
        name: small.pageName,
        isPublic: small.state.publicallyViewable,
      );

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.group),
      title: Text(name.isNotEmpty ? name : '(Untitled room $id)'),
      subtitle: Text('${isPublic ? 'Public' : 'Private'} room'),
    );
  }
}
