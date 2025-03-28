import 'dart:convert';

Duration fromDurationString(String duration) {
  final [days, hours, minutes, seconds, milliseconds] =
      duration.split(RegExp('.:')).map((p) => int.parse(p)).toList();
  return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
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
