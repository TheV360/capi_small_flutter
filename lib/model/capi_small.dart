import 'package:capi_small_mvp/csv_parser.dart';

typedef CapiPageId = int;
typedef CapiMessageId = int;

class CapiSmallState {
  final bool edited;
  final bool deleted;
  final bool publiclyViewable;
  final bool userCanPostInRoom;
  final bool userOwnsRoom;

  const CapiSmallState({
    required this.edited,
    required this.deleted,
    required this.publiclyViewable,
    required this.userCanPostInRoom,
    required this.userOwnsRoom,
  });

  factory CapiSmallState.parse(String flags) => CapiSmallState(
        edited: flags.contains('E'),
        deleted: flags.contains('D'),
        publiclyViewable: flags.contains('R'),
        userCanPostInRoom: flags.contains('P'),
        userOwnsRoom: flags.contains('O'),
      );

  @override
  String toString() {
    return '${edited ? 'E' : ''}'
        '${deleted ? 'D' : ''}'
        '${publiclyViewable ? 'R' : ''}'
        '${userCanPostInRoom ? 'P' : ''}'
        '${userOwnsRoom ? 'O' : ''}';
  }
}

class CapiSmall {
  final String pageName;
  final String userName;
  final String message;
  final DateTime? postedAt;
  final String module;
  final CapiSmallState state;
  final CapiPageId? pageId;
  final int? userId;
  final CapiMessageId? messageId;

  const CapiSmall({
    required this.pageName,
    required this.userName,
    required this.message,
    required this.postedAt,
    required this.module,
    required this.state,
    required this.pageId,
    required this.userId,
    required this.messageId,
  });

  factory CapiSmall.fromCsvRow(List<String> row) => switch (row) {
        [
          String pageName,
          String userName,
          String message,
          String postedAt,
          String module,
          String state,
          String pageId,
          String userId,
          String messageId,
        ] =>
          CapiSmall(
            pageName: pageName,
            userName: userName,
            message: message,
            postedAt: DateTime.tryParse(postedAt),
            module: module,
            state: CapiSmallState.parse(state),
            pageId: int.tryParse(pageId),
            userId: int.tryParse(userId),
            messageId: int.tryParse(messageId),
          ),
        _ => throw const FormatException("not to code"),
      };

  static List<CapiSmall> fromCsv(String text) {
    return parseCsv(text).map((row) => CapiSmall.fromCsvRow(row)).toList();
  }
}
