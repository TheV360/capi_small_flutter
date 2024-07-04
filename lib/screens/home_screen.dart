import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/network/capi_small.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const appName = "Caterpie";

  final String token;

  const HomeScreen({required this.token, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<CapiSmall>> rooms;
  late final Future<CapiProfile> profile;
  final SearchController searchController = SearchController();

  @override
  void initState() {
    super.initState();
    profile = fetchMe(token: widget.token);
    rooms = fetchSearch('', token: widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: rooms,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: <Widget>[
              _sliverAppBar(),
              if (snapshot.hasData && snapshot.data!.isNotEmpty)
                SliverList.list(
                  children: snapshot.data!.map(RoomItem.fromSmall).toList(),
                )
              else if (snapshot.hasData && snapshot.data!.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Got nothing!')),
                )
              else if (snapshot.hasError)
                SliverFillRemaining(
                  child: Center(
                    child: ListTile(
                      leading: const Icon(Icons.error),
                      title: const Text('Failed!'),
                      subtitle: Text(snapshot.error.toString()),
                    ),
                  ),
                )
              else
                const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator())),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _sliverAppBar() {
    return SliverAppBar(
      // title: SearchAnchor.bar(suggestionsBuilder: suggestionsBuilder),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () {},
          icon: FutureBuilder(
            future: profile,
            builder: (context, snapshot) => CircleAvatar(
              backgroundImage: snapshot.hasData
                  ? NetworkImage(getPathToImage(snapshot.data!.avatar))
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
