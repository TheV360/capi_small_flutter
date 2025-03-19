import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/debouncable.dart';
import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/widgets/room_data.dart';
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
    final client = context.read<CapiClient>();
    final query = text.trim();
    _runningQuery = query;
    final int? roomId = switch (RegExp(r'^#(\d+)$').firstMatch(query)) {
      final match? => int.tryParse(match.group(1) ?? ''),
      _ => null,
    };
    final results = await (roomId == null
        ? client.fetchSearchByName(query)
        : client.fetchSearchById(roomId));
    if (query != _runningQuery) {
      // oops! took too long and the user wrote something else. sucks to suck
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
          return _lastResults
              .map((small) => (small: small, room: Room.fromSmall(small)))
              .map((out) => ListTile(
                    leading: out.room.getRoomIcon(),
                    title: Text(out.room.name.isNotEmpty
                        ? out.room.name
                        : '(Untitled room ${out.room.id})'),
                    subtitle: Text(out.room.describeRoomType()),
                    onTap: () {
                      final roomsData = context.read<RoomsData>();
                      roomsData.recognizeRoom(out.small);
                      selection.selectRoom(out.room);
                      controller.closeView(null);
                    },
                    selected: selection.selectedRoom?.id == out.room.id,
                  ));
        },
      ),
    );
  }
}
