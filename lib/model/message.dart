import 'package:capi_small_mvp/model/capi_small.dart';

class Message {
  final CapiSmall inner;

  CapiMessageId get id => inner.messageId!;
  CapiPageId get pageId => inner.pageId!;

  CapiUserId get userId => inner.userId!;
  String get userName => inner.userName;
  String get module => inner.module;

  DateTime get postedAt => inner.postedAt!;
  String get message => inner.message;

  bool get isEdited => inner.state.edited;
  bool get isDeleted => inner.state.deleted;
  bool get isUserRecipient => inner.state.userIsRecipient;

  const Message(this.inner);
}
