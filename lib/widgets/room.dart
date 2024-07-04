import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:flutter/material.dart';

class Room extends StatelessWidget {
  final CapiSmall inner;

  const Room({super.key, required this.inner});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const Icon(Icons.group),
        title: Text(inner.pageName),
        subtitle: Text(
            '${inner.state.publicallyViewable ? 'Public' : 'Private'} room'));
  }
}
