// Represents the account information and statistics stored for a user
class UserAccount {
  final String uid;
  final String username;
  final String email;
  final int routesCompleted;
  final int photosTaken;

  const UserAccount({
    required this.uid,
    required this.username,
    required this.email,
    this.routesCompleted = 0,
    this.photosTaken = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'routesCompleted': routesCompleted,
      'photosTaken': photosTaken,
    };
  }
}
