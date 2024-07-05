import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/model/capi_profile.dart';
import 'package:capi_small_mvp/network/capi_small.dart';
import 'package:capi_small_mvp/screens/login_screen.dart';
import 'package:capi_small_mvp/widgets/room_chat.dart';
import 'package:capi_small_mvp/widgets/room_search.dart';
import 'package:capi_small_mvp/widgets/room_selector.dart';

class HomeScreen extends StatefulWidget {
  static const appName = "Caterpie";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<CapiProfile> profile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profile = Provider.of<CapiClient>(context).fetchMe();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RoomSelection>(
            create: (context) => RoomSelection()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const RoomSearch(),
          actions: [
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.logout),
                  child: const Text('Log out'),
                  onPressed: () {
                    Provider.of<CapiClient>(context, listen: false)
                        .forgetToken();
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
                  tooltip: snapshot.hasData ? snapshot.data!.username : null,
                  icon: CircleAvatar(
                    backgroundImage: snapshot.hasData
                        ? NetworkImage(Provider.of<CapiClient>(context)
                            .getPathToImage(snapshot.data!.avatar))
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
            ),
          ],
        ),
        body: const SafeArea(
          child: Row(children: [
            Flexible(
              flex: 1,
              child: RoomPicker(),
            ),
            Flexible(
              flex: 2,
              child:
                  RoomChat(), /* StreamProvider(
                create: (context) {},
                builder: (context, child) => ,
              ),*/
            ),
          ]),
        ),
      ),
    );
  }
}
