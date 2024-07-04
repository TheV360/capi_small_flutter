import 'package:capi_small_mvp/csv_parser.dart';

class CapiSmallState {
  final bool edited;
  final bool deleted;
  final bool publicallyViewable;
  final bool userCanPostInRoom;
  final bool userOwnsRoom;

  const CapiSmallState({
    required this.edited,
    required this.deleted,
    required this.publicallyViewable,
    required this.userCanPostInRoom,
    required this.userOwnsRoom,
  });

  factory CapiSmallState.parse(String flags) => CapiSmallState(
        edited: flags.contains('E'),
        deleted: flags.contains('D'),
        publicallyViewable: flags.contains('R'),
        userCanPostInRoom: flags.contains('P'),
        userOwnsRoom: flags.contains('O'),
      );

  @override
  String toString() {
    return '${edited ? 'E' : ''}'
        '${deleted ? 'D' : ''}'
        '${publicallyViewable ? 'R' : ''}'
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
  final int pageId;
  final int? userId;
  final int? messageId;

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

  factory CapiSmall.fromCsvRow(List<String> row) {
    return switch (row) {
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
          pageId: int.parse(pageId),
          userId: int.tryParse(userId),
          messageId: int.tryParse(messageId),
        ),
      _ => throw const FormatException("not to code"),
    };
  }

  static List<CapiSmall> fromCsv(String text) {
    return parseCsv(text).map((row) => CapiSmall.fromCsvRow(row)).toList();
  }
}
