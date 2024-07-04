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
  final List<Room> roomHistory = [];
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
          barElevation: const WidgetStatePropertyAll(0.0),
          barHintText: 'Find a room',
          // searchController: searchController,
          suggestionsBuilder: (context, controller) async {
            final query = controller.text;
            final results =
                (await fetchSearch(query, token: widget.token)).map((r) {
              final i = Room.fromSmall(r);
              return ListTile(
                leading: i.isPublic
                    ? const Icon(Icons.groups_2)
                    : const Icon(Icons.group),
                title:
                    Text(i.name.isNotEmpty ? i.name : '(Untitled room $i.id)'),
                subtitle: Text('${i.isPublic ? 'Public' : 'Private'} room'),
                onTap: () {
                  setState(() => roomHistory.add(i));
                },
              );
            });
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
      body: ListView(
        children: roomHistory
            .map((i) => ListTile(
                  leading: i.isPublic
                      ? const Icon(Icons.groups_2)
                      : const Icon(Icons.group),
                  title: Text(
                      i.name.isNotEmpty ? i.name : '(Untitled room $i.id)'),
                  subtitle: Text('${i.isPublic ? 'Public' : 'Private'} room'),
                  onTap: () {},
                ))
            .toList(),
      ),
    );
  }
}
