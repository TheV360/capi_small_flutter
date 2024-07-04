import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/network/capi_small.dart';
import 'package:capi_small_mvp/widgets/chat_message.dart';
import 'package:capi_small_mvp/widgets/room.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class AuthToken with ChangeNotifier {
  String? _token;

  String? get token => _token;
  set token(String? value) {
    if (_token == value) return;
    if (_token != null && _token!.isEmpty) {
      throw const FormatException('fuuck');
    }

    _token = value;
    notifyListeners();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: HomeScreen.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  static const appName = "Caterpie";

  final String token;

  const HomeScreen({required this.token, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<CapiSmall>> rooms;
  final SearchController searchController = SearchController();

  @override
  void initState() {
    super.initState();
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
                  children: snapshot.data!.map((r) => Room(inner: r)).toList(),
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
          icon: const CircleAvatar(
            backgroundColor: Colors.black26,
            child: Text('Vi', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _inProgress = false;

  void showSnackBarMessage(SnackBar the) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(the);
  }

  void _doLogin() async {
    setState(() => _inProgress = true);

    final username = usernameController.text;
    final password = passwordController.text;

    try {
      final token = await fetchToken(username, password);
      if (!mounted) return; // -> can't really do anything..
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
      );
    } on UserNotFoundException {
      showSnackBarMessage(const SnackBar(content: Text('User not found.')));
    } on AuthorizationException {
      showSnackBarMessage(const SnackBar(content: Text('Wrong password.')));
    } catch (other) {
      showSnackBarMessage(SnackBar(
        content: const Text('Unknown error.'),
        action: SnackBarAction(
          label: 'Details',
          onPressed: () => showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Text(other.toString()),
            ),
          ),
        ),
      ));
    }

    setState(() => _inProgress = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log in'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: usernameController,
                maxLines: 1,
                decoration: const InputDecoration(
                  icon: Icon(Icons.catching_pokemon),
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a username.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                enabled: !_inProgress,
                maxLines: 1,
                obscureText: true,
                decoration: const InputDecoration(
                  icon: Icon(Icons.key),
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a password.';
                  } else if (value.length < 4) {
                    return 'Enter a longer password.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _inProgress ? null : _doLogin,
                child: _inProgress
                    ? const CircularProgressIndicator()
                    : const Text('Log in'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// login page leads to home page where it might just say "search for a pgae"
// and then you press the search button and it opens up a modal ontop of the app
// whihc has the big search bar and you enter in your query


// soooo the login is a state thing. let's use the local storage package i just
// brought in (the one that indeed does have problems with safely saving stuff)
// and we'll use https://pub.dev/packages/provider too, to provide the token
// and be able to notify people when you need to log in again.
//
// but also like you can browse contentapi without logging in. so it's still valid to alskdfjaslkf
