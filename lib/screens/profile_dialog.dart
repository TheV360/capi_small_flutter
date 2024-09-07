import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:capi_small_mvp/network/capi_client.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final avatarController = TextEditingController();

  late final CapiClient _client;

  var dummyImageHash = 'gbinp';

  @override
  void initState() {
    super.initState();
    _client = context.read<CapiClient>();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Modifications to this are saved locally, but'
            ' not committed to your profile on the server.',
          ),
          const Text(
            'Nicknames will only be visible to other users,'
            ' as the small API does not get nickname info.',
          ),
          TextFormField(
            controller: nicknameController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Nickname',
              suffixIcon: IconButton(
                onPressed: () => nicknameController.clear(),
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
          TextFormField(
            controller: avatarController,
            maxLines: 1,
            onChanged: (newString) {
              setState(() {
                dummyImageHash = newString;
              });
            },
            decoration: InputDecoration(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(
                  _client.getPathToImage(dummyImageHash),
                ),
              ),
              labelText: 'Avatar',
              hintText: 'Image Hash',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    dummyImageHash = avatarController.text = "dbugm";
                  });
                },
                icon: const Icon(Icons.undo),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Save'),
        ),
      ],
    );
  }
}
