import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/network/capi_small.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';

class RoomSearch extends StatelessWidget {
  const RoomSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CapiClient, RoomSelection>(
      builder: (context, client, selection, _) => SearchAnchor.bar(
        barElevation: const WidgetStatePropertyAll(0.0),
        barHintText: 'Find a room',
        suggestionsBuilder: (context, controller) async {
          final query = controller.text.trim();
          final int? roomId = switch (RegExp(r'^#(\d+)$').firstMatch(query)) {
            final match? => switch (match.group(0)) {
                final roomIdStr? => int.parse(roomIdStr),
                _ => null,
              },
            _ => null,
          };
          final results = await (roomId == null
              ? client.fetchSearchByName(query)
              : client.fetchSearchById(roomId));
          return results.map(Room.fromSmall).map((i) => ListTile(
                leading: i.isPublic
                    ? const Icon(Icons.groups_2)
                    : const Icon(Icons.group),
                title:
                    Text(i.name.isNotEmpty ? i.name : '(Untitled room $i.id)'),
                subtitle: Text('${i.isPublic ? 'Public' : 'Private'} room'),
                onTap: () => selection.selectRoom(i),
                selected: selection.selectedRoom?.id == i.id,
              ));
        },
      ),
    );
  }
}
