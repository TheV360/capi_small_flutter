import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'login screen');
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late FocusNode usernameFocusNode;
  late FocusNode passwordFocusNode;

  bool _inProgress = false;

  void _showSnackBarMessage(SnackBar the) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(the);
  }

  void _doLogin() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _inProgress = true);

    final username = usernameController.text;
    final password = passwordController.text;

    try {
      // token is saved in the state of CapiClient.
      await context.read<CapiClient>().fetchAndSaveToken(username, password);

      if (!mounted) return; // -> can't really do anything..

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on UserNotFoundException {
      _showSnackBarMessage(const SnackBar(content: Text('User not found.')));
      usernameFocusNode.requestFocus();
    } on AuthorizationException {
      _showSnackBarMessage(const SnackBar(content: Text('Wrong password.')));
      passwordFocusNode.requestFocus();
    } catch (other) {
      _showSnackBarMessage(
        SnackBar(
          content: const Text('Unknown error.'),
          action: SnackBarAction(
            label: 'Details',
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Unknown error.'),
                content: Text(other.toString()),
              ),
            ),
          ),
        ),
      );
    }

    setState(() => _inProgress = false);
  }

  @override
  void initState() {
    super.initState();
    usernameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
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
      persistentFooterButtons: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: _inProgress ? null : _doLogin,
            child: const Text('Log in'),
          ),
        ),
      ],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(const Size.fromWidth(360)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            autofocus: true,
            controller: usernameController,
            focusNode: usernameFocusNode,
            enabled: !_inProgress,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              icon: Icon(Icons.catching_pokemon),
              labelText: 'Username',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter a username.';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            enabled: !_inProgress,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
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
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _inProgress ? null : (_) => _doLogin(),
          ),
        ],
      ),
    );
  }
}
