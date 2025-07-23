class UserModel {
  final String id;
  final Uri pictureUrl;
  final String name;
  final String email;
  final bool emailVerified;
  final DateTime lastUpdated;

  UserModel(
      {required this.id,
      required this.pictureUrl,
      required this.name,
      required this.email,
      required this.emailVerified,
      required this.lastUpdated});
}
