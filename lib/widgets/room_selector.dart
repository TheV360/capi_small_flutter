import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/model/capi_small.dart';

class Room {
  final int id;
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
        isPublic: small.state.publicallyViewable,
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

class RoomSelection extends ChangeNotifier {
  List<Room> rooms = [];
  Room? selectedRoom;

  void selectRoom(Room room) {
    if (!rooms.any((o) => o.id == room.id)) {
      rooms.insert(0, room);
    } else if (room.id == selectedRoom?.id) {
      return;
    }
    selectedRoom = room;
    notifyListeners();
  }
}

class RoomSelector extends StatelessWidget {
  const RoomSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSelection>(
      builder: (context, value, child) {
        return value.rooms.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Search for a room, and it'll be added to your room list.\n"
                    "Then, you can freely switch between the rooms.",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView(
                children: value.rooms
                    .map((room) => ListTile(
                          leading: room.getRoomIcon(),
                          title: Text(room.name.isNotEmpty
                              ? room.name
                              : '(Untitled room ${room.id})'),
                          subtitle: Text(room.describeRoomType()),
                          onTap: () => value.selectRoom(room),
                          selected: value.selectedRoom?.id == room.id,
                          selectedTileColor: Theme.of(context).highlightColor,
                        ))
                    .toList(),
              );
      },
    );
  }
}
