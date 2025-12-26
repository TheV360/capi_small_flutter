import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/screens/instance_screen.dart';
import 'package:capi_small_mvp/screens/login_screen.dart';
import 'package:capi_small_mvp/screens/home_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    // https://api.flutter.dev/flutter/widgets/Navigator-class.html
    final seedColor = Colors.amber;
    return Provider<CapiClient>(
      create: (_) => CapiClient(),
      dispose: (_, value) => value.dispose(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: HomeScreen.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const InstanceScreen(),
      ),
    );
  }
}

// TODO: login page's focus nodes don't work

// login page leads to home page where it might just say "search for a pgae"
// and then you press the search button and it opens up a modal ontop of the app
// whihc has the big search bar and you enter in your query


// soooo the login is a state thing. let's use the local storage package i just
// brought in (the one that indeed does have problems with safely saving stuff)
// and we'll use https://pub.dev/packages/provider too, to provide the token
// and be able to notify people when you need to log in again.
//
// but also like you can browse contentapi without logging in. so it's still valid to alskdfjaslkf

// sources
// https://www.mundanecode.com/posts/login-flow-in-flutter/ - it's kinda broken and it uses old navigator patterns
// https://github.com/Trindade7/two_columns/tree/main/lib - it's janky old but it's literally exactly what i want
// https://codelabs.developers.google.com/codelabs/flutter-animated-responsive-layout#5 - completely bogged down by the part where they add wacky intricate animations. i'm still jamming! i can't add animations yet!
// https://youtu.be/LeKLGzpsz9I?t=831 - mediaquery things to keep in mind

// https://raw.githubusercontent.com/dart-lang/http/master/pkgs/cronet_http/example/lib/main.dart
// https://blog.burkharts.net/everything-you-always-wanted-to-know-about-httpclients - are they trying to sell me something

// https://pub.dev/packages/dynamic_color
// -> https://dartling.dev/dynamic-theme-color-material-3-you-flutter

// https://m3.material.io/foundations/layout/understanding-layout/parts-of-layout#17dcca34-ce17-40d7-8b3f-a7186dfb5fc2
