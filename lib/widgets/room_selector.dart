import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/model/room.dart';

class RoomSelection with ChangeNotifier {
  List<Room> listenedRooms = [];
  Room? selectedRoom;

  get listenedRoomIds => listenedRooms.map((o) => o.id).toList();

  // this should really only notify listeners on add/removing rooms from the picker,
  // and some other resource should package the actual selected room
  void selectRoom(Room room) {
    if (!listenedRooms.any((o) => o.id == room.id)) {
      listenedRooms.insert(0, room);
    } else if (room.id == selectedRoom?.id) {
      return;
    }
    selectedRoom = room;
    notifyListeners();
  }

  void dismissRoom(Room room) {
    if (room.id == selectedRoom?.id) {
      selectedRoom = null;
    }
    listenedRooms.removeWhere((o) => o.id == room.id);
    notifyListeners();
  }
}

class RoomSelector extends StatelessWidget {
  const RoomSelector({super.key});

  Widget noRooms(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Search for a room, and it'll be added to your room list.\n"
          "Then, you can freely switch between the rooms.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget listRooms(BuildContext context, RoomSelection pick) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      children: pick.listenedRooms
          .map((room) => ListTile(
                leading: MenuAnchor(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () => pick.dismissRoom(room),
                      leadingIcon: const Icon(Icons.close),
                      child: const Text("Dismiss"),
                    )
                  ],
                  builder: (_, controller, __) => IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: room.getRoomIcon(),
                  ),
                ),
                title: Text(room.name.isNotEmpty
                    ? room.name
                    : '(Untitled room ${room.id})'),
                subtitle: Text(room.describeRoomType()),
                onTap: () => pick.selectRoom(room),
                selected: pick.selectedRoom?.id == room.id,
                selectedTileColor: Theme.of(context).highlightColor,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSelection>(
      builder: (context, pick, _) => pick.listenedRooms.isEmpty
          ? noRooms(context)
          : listRooms(context, pick),
    );
  }
}
