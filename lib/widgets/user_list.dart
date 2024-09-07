import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final List<String> users;

  const UserList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    // evaluates all items in the list anyway because most of em are gonna be
    // visible anyway. and also we're not going to re-build a billion items.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: users
            .map((user) => Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Chip(
                    label: Text(user),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
