import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/screens/login_screen.dart';
import 'package:capi_small_mvp/screens/profile_dialog.dart';
import 'package:capi_small_mvp/widgets/compose_box.dart';
import 'package:capi_small_mvp/widgets/room_chat.dart';
import 'package:capi_small_mvp/widgets/room_search.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';
import 'package:capi_small_mvp/widgets/room_data.dart';
import 'package:capi_small_mvp/widgets/user_list.dart';

class HomeScreen extends StatefulWidget {
  static const appName = "Caterpie";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CapiClient _client;
  late Future<CapiProfile> profile;

  static const double breakpoint = 700;

  void _logOut() {
    _client.forgetToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _client = context.read<CapiClient>();

    // TODO: why does this get called twice in didChangeDependencies?
    // plus, should it not be `final` if it could change?
    profile = _client.fetchMe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final twoPane = MediaQuery.sizeOf(context).width > breakpoint;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoomsData()..listen(_client)),
        ChangeNotifierProvider(create: (_) => RoomSelection()),
      ],
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Consumer<RoomsData>(
              builder: (context, roomsData, _) =>
                  UserList(users: roomsData.globalUserList.toList())),
          actions: [userMenuAnchor(context)],
        ),
        drawer: twoPane
            ? null
            : SafeArea(
                child: Drawer(child: roomSelectionPane()),
              ),
        body: SafeArea(
          child: Row(
            children: [
              if (twoPane) SizedBox(width: 250, child: roomSelectionPane()),
              Expanded(child: roomContentPane()),
            ],
          ),
        ),
      ),
    );
  }

  MenuAnchor userMenuAnchor(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.badge),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ProfileDialog(),
          ),
          child: const Text('Edit profile'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout),
          onPressed: () => _logOut(),
          child: const Text('Log out'),
        ),
      ],
      builder: (_, controller, __) => FutureBuilder(
        future: profile,
        builder: (_, snapshot) => TextButton.icon(
          iconAlignment: IconAlignment.end,
          // Tooltip can be annoying and overlap with menu, so i've
          // switched from an IconButton to a TextButton with icon
          label: snapshot.hasData
              ? Text(snapshot.data!.username)
              : const Text("Dummy"),
          icon: CircleAvatar(
            backgroundImage: snapshot.hasData
                ? NetworkImage(_client.getPathToImage(snapshot.data!.avatar))
                : null,
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        ),
      ),
    );
  }

  Widget roomSelectionPane() {
    return const Column(
      children: [
        RoomSearch(),
        Expanded(child: RoomSelector()),
      ],
    );
  }

  Widget roomContentPane() {
    return Consumer<RoomSelection>(builder: (context, selection, _) {
      if (selection.selectedRoom == null) {
        return const Center(child: Text("No room has been selected."));
      }
      final selectedRoom = selection.selectedRoom!;
      final roomData = context.read<RoomsData>().getRoomById(selectedRoom.id);
      if (roomData == null) {
        return const Center(child: Text("Something weird happened."));
      }
      return Column(
        children: [
          ListenableBuilder(
              listenable: roomData.userList,
              builder: (context, _) =>
                  UserList(users: roomData.userList.toList())),
          Expanded(
            child: RoomChat(
              key: ValueKey(selectedRoom.id),
              room: selectedRoom,
            ),
          ),
          if (!selectedRoom.isReadOnly) const ComposeBox(),
        ],
      );
    });
  }
}
