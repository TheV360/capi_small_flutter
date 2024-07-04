class CapiProfile {
  final int id;
  final String username;
  final String avatar;

  bool get hasAvatar => avatar.isNotEmpty;

  const CapiProfile({
    required this.id,
    required this.username,
    required this.avatar,
  });

  factory CapiProfile.fromCsvRow(List<String> row) => switch (row) {
        [
          String id,
          String username,
          String avatar,
        ] =>
          CapiProfile(id: int.parse(id), username: username, avatar: avatar),
        _ => throw const FormatException("other error message")
      };
}
