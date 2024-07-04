import 'package:capi_small_mvp/model/capi_small.dart';

class Room {
  final int id;
  final String name;
  final bool isPublic;

  const Room({
    required this.id,
    required this.name,
    required this.isPublic,
  });

  factory Room.fromSmall(CapiSmall small) => Room(
        id: small.pageId,
        name: small.pageName,
        isPublic: small.state.publicallyViewable,
      );
}
