import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

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

class RoomPicker extends StatelessWidget {
  const RoomPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSelection>(
      builder: (context, value, child) {
        return value.rooms.isEmpty
            ? const Center(child: Text('Search for a room to begin'))
            : ListView(
                children: value.rooms
                    .map((i) => ListTile(
                          leading: i.isPublic
                              ? const Icon(Icons.groups_2)
                              : const Icon(Icons.group),
                          title: Text(i.name.isNotEmpty
                              ? i.name
                              : '(Untitled room $i.id)'),
                          subtitle:
                              Text('${i.isPublic ? 'Public' : 'Private'} room'),
                          onTap: () => value.selectRoom(i),
                          selected: value.selectedRoom?.id == i.id,
                          selectedTileColor: Theme.of(context).highlightColor,
                        ))
                    .toList(),
              );
      },
    );
  }
}
