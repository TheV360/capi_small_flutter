import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:capi_small_mvp/model/capi_instance_status.dart';

class InstanceStatus extends StatefulWidget {
  const InstanceStatus({super.key});

  @override
  State<InstanceStatus> createState() => _InstanceStatusState();
}

class _InstanceStatusState extends State<InstanceStatus> {
  CapiInstanceStatus? instanceStatus;

  @override
  Widget build(BuildContext context) {
    return Text("hi");
  }
}
