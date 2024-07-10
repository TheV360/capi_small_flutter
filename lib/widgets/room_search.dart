import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/debouncable.dart';
import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';

class RoomSearch extends StatefulWidget {
  const RoomSearch({super.key});

  @override
  State<RoomSearch> createState() => _RoomSearchState();
}

class _RoomSearchState extends State<RoomSearch> {
  late final Debounceable<List<CapiSmall>, String> _debouncedSearch;
  String? _runningQuery;
  List<CapiSmall> _lastResults = [];

  Future<List<CapiSmall>?> _search(String text) async {
    final client = Provider.of<CapiClient>(context, listen: false);
    final query = text.trim();
    _runningQuery = query;
    print("starting query '$query'");
    final int? roomId = switch (RegExp(r'^#(\d+)$').firstMatch(query)) {
      final match? => int.tryParse(match.group(1) ?? ''),
      _ => null,
    };
    final results = await (roomId == null
        ? client.fetchSearchByName(query)
        : client.fetchSearchById(roomId));
    print("done with query '$query'");
    if (query != _runningQuery) {
      // oops! took too long and the user wrote something else. sucks to suck
      print("throwing away query '$query'");
      return null;
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = debounce(_search);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomSelection>(
      builder: (context, selection, _) => SearchAnchor.bar(
        // remove the shadow by removing all elevation
        barElevation: const WidgetStatePropertyAll(0.0),
        barHintText: 'Find a room',
        suggestionsBuilder: (context, controller) async {
          final freshResults = await _debouncedSearch(controller.text);
          _lastResults = freshResults ?? _lastResults;
          return _lastResults.map(Room.fromSmall).map((room) => ListTile(
                leading: room.isPublic
                    ? const Icon(Icons.groups_2)
                    : const Icon(Icons.group),
                title: Text(room.name.isNotEmpty
                    ? room.name
                    : '(Untitled room ${room.id})'),
                subtitle: Text('${room.isPublic ? 'Public' : 'Private'} room'),
                onTap: () {
                  selection.selectRoom(room);
                  controller.closeView(null);
                },
                selected: selection.selectedRoom?.id == room.id,
              ));
        },
      ),
    );
  }
}
