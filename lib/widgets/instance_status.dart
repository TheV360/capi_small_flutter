import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:capi_small_mvp/model/capi_instance_status.dart';

class InstanceStatus extends StatelessWidget {
  const InstanceStatus(this.instanceStatus, {super.key});

  final CapiInstanceStatus instanceStatus;

  @override
  Widget build(BuildContext context) {
    final i = instanceStatus;
    return Text.rich(
      TextSpan(
        text: '${i.appname} version ${i.version}\n',
        children: <InlineSpan> [
          TextSpan(text: 'configured for ${i.environment.toLowerCase()}\n'),
          TextSpan(text: 'started at ${i.processStart}\n'),
          TextSpan(text: 'running for ${i.runtime}\n'),
          TextSpan(text: 'source code at ${i.repositoryUrl}\n'),
          TextSpan(text: 'report bugs at ${i.bugReportingUrl}\n'),
          TextSpan(text: 'contact at ${i.contactEmail}\n'),
        ],
      ),
    );
  }
}
