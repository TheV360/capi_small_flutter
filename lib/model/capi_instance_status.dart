import 'dart:convert';

Duration fromDurationString(String duration) {
  final splitDuration =
      duration.split(RegExp('[.:]')).map((p) => int.tryParse(p) ?? 0).toList();
  return Duration(
    days:
        splitDuration.length >= 5 ? splitDuration[splitDuration.length - 5] : 0,
    hours:
        splitDuration.length >= 4 ? splitDuration[splitDuration.length - 4] : 0,
    minutes:
        splitDuration.length >= 3 ? splitDuration[splitDuration.length - 3] : 0,
    seconds:
        splitDuration.length >= 2 ? splitDuration[splitDuration.length - 2] : 0,
    milliseconds:
        splitDuration.length >= 1 ? splitDuration[splitDuration.length - 1] : 0,
  );
}

class CapiInstanceStatus {
  final String version;
  final String appname;
  final String environment;
  final DateTime processStart;
  final Duration runtime;
  final String repositoryUrl;
  final String bugReportingUrl;
  final String contactEmail;

  const CapiInstanceStatus({
    required this.version,
    required this.appname,
    required this.environment,
    required this.processStart,
    required this.runtime,
    required this.repositoryUrl,
    required this.bugReportingUrl,
    required this.contactEmail,
  });

  CapiInstanceStatus.fromJson(Map<String, dynamic> json)
      : version = json['version'] as String,
        appname = json['appname'] as String,
        environment = json['environment'] as String,
        processStart = DateTime.parse(json['processStart'] as String),
        runtime = fromDurationString(json['runtime'] as String),
        repositoryUrl = json['repo'] as String,
        bugReportingUrl = json['bugreport'] as String,
        contactEmail = json['contact'] as String;
}
