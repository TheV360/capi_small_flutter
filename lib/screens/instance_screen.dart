import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/model/capi_instance_status.dart';
import 'package:capi_small_mvp/network/capi_client.dart';
import 'package:capi_small_mvp/widgets/instance_status.dart';
import 'package:capi_small_mvp/screens/login_screen.dart';

class InstanceScreen extends StatefulWidget {
  const InstanceScreen({super.key});

  @override
  State<InstanceScreen> createState() => _InstanceScreenState();
}

class _InstanceScreenState extends State<InstanceScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController instanceUriController = TextEditingController();
  TextEditingController tempRoomIdController = TextEditingController();

  bool _inProgress = false;

  void _showSnackBarMessage(SnackBar the) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(the);
  }

  void _doCheckInstance() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _inProgress = true);

    // todo: distinguish without/with `/api`
    final instanceUri = instanceUriController.text;

    final tempRoomId = tempRoomIdController.text;

    try {
      final parsedInstanceUri = Uri.parse(instanceUri);
      await context
          .read<CapiClient>()
          .fetchAndSaveInstanceStatus(parsedInstanceUri);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to instance'),
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
            onPressed: _inProgress ? null : _doCheckInstance,
            child: const Text('Use this instance'),
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
          // TODO: handle overflows
          TextFormField(
            autofocus: true,
            controller: instanceUriController,
            enabled: !_inProgress,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              icon: Icon(Icons.dns),
              labelText: 'Instance URI',
              hintText: 'http://localhost:5147',
              suffixText: '/api',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter an instance URI.';
              }
              final parsed = Uri.tryParse(value);
              if (parsed == null) {
                return 'Enter a valid instance URI.';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            autofocus: true,
            controller: tempRoomIdController,
            enabled: !_inProgress,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              icon: Icon(Icons.description),
              labelText: 'temp room id to listen to',
              hintText: '95',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'if u dont enter a room id then u will pass away.';
              }
              final parsed = int.tryParse(value);
              if (parsed == null) {
                return 'you gotta enter a number kinda thing.';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16.0),
          Card.outlined(
            margin: EdgeInsets.zero,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              constraints: const BoxConstraints.expand(height: 200.0),
              child: FutureBuilder(
                future: Future.value(CapiInstanceStatus.fromJson(json.decode("""
                            {
                              "version": "3.3.2.740",
                              "appname": "contentapi",
                              "environment": "Production",
                              "processStart": "2025-03-13T06:41:10.878Z",
                              "runtime": "18.14:07:38.9706183",
                              "repo": "https://github.com/randomouscrap98/contentapi",
                              "bugreport": "https://github.com/randomouscrap98/contentapi/issues",
                              "contact": "smilebasicsource@gmail.com"
                            }
                            """))),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return InstanceStatus(snapshot.data!);
                  } else {
                    return const Center(child: Text('Nothing'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
