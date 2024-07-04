import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/network/capi_small.dart';
import 'package:capi_small_mvp/screens/login_screen.dart';
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
  late final Future<CapiProfile> profile;
  final List<RoomItem> roomHistory = [];
  // final SearchController searchController = SearchController();

  @override
  void initState() {
    super.initState();
    profile = fetchMe(token: widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchAnchor.bar(
          // searchController: searchController,
          suggestionsBuilder: (context, controller) async {
            final query = controller.text;
            final results = (await fetchSearch(query, token: widget.token))
                .map(RoomItem.fromSmall);
            return results;
          },
        ),
        actions: [
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.logout),
                child: const Text('Log out'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
            builder: (context, controller, child) => FutureBuilder(
              future: profile,
              builder: (context, snapshot) => IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: CircleAvatar(
                  backgroundImage: snapshot.hasData
                      ? NetworkImage(getPathToImage(snapshot.data!.avatar))
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          Placeholder(), /*FutureBuilder(
        future: searchResults,
        builder: (context, snapshot) {
          return CustomScrollView(
            slivers: <Widget>[
              if (snapshot.hasData && snapshot.data!.isNotEmpty)
                SliverList.list(
                  children: snapshot.data!
                      .map(RoomItem.fromSmall)
                      .where((i) => i.name.isNotEmpty)
                      .toList(),
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
      ),*/
    );
  }
}
