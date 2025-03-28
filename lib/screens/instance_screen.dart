import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class InstanceScreen extends StatefulWidget {
  const InstanceScreen({super.key});

  @override
  State<InstanceScreen> createState() => _InstanceScreenState();
}

class _InstanceScreenState extends State<InstanceScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController instanceUriController = TextEditingController();

  bool _inProgress = false;

  void _doCheckInstance() async {
    
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(const Size.fromWidth(360)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: instanceUriController,
                      enabled: !_inProgress,
                      decoration: const InputDecoration(
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
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _inProgress ? null : _doCheckInstance,
                      child: const Text('Check instance'),
                    ),
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
