import 'package:capi_small_mvp/model/capi_small.dart';

class Message {
  final CapiMessageId id;
  final CapiPageId pageId;

  final CapiUserId userId;
  final String userName;
  final String module;

  final DateTime postedAt;
  final String message;

  final bool isEdited;
  final bool isDeleted;
  final bool isUserRecipient;

  const Message({
    required CapiMessageId id,
    required CapiPageId pageId,
    required CapiUserId userId,
    required String userName,
    required String module,
    required DateTime postedAt,
    required String message,
    required bool isEdited,
    required bool isDeleted,
    required bool isUserRecipient,
  });

  factory Message.fromSmall(CapiSmall small) => Message(
        id: small.messageId!,
        pageId: small.pageId!,
        userId: small.userId!,
        userName: small.userName,
        module: small.module,
        postedAt: small.postedAt!,
        message: small.message,
        isEdited: small.state.edited,
        isDeleted: small.state.deleted,
        isUserRecipient: small.state.userIsRecipient,
      );
}
