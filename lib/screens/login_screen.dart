import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/network/capi_small.dart';
import 'package:capi_small_mvp/screens/home_screen.dart';

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
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    setState(() => _inProgress = true);

    final username = usernameController.text;
    final password = passwordController.text;

    try {
      // token is saved in the state of CapiClient.
      await Provider.of<CapiClient>(context, listen: false)
          .fetchToken(username, password);

      if (!mounted) return; // -> can't really do anything..

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 4),
          child: Visibility(
            visible: _inProgress,
            child: const LinearProgressIndicator(),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(const Size.fromWidth(360)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    TextFormField(
                      controller: usernameController,
                      enabled: !_inProgress,
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
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _inProgress ? null : _doLogin,
                      child: const Text('Log in'),
                    ),
                    const Spacer(flex: 3)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
