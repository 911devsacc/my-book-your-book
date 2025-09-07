class UserData {
  final String profilePic;
  final String gender;

  const UserData({required this.profilePic, required this.gender});

  factory UserData.fromMap(Map<String, dynamic>? data) {
    return UserData(
      profilePic: data?['profilePic'] ?? '',
      gender: data?['gender'] ?? 'male',
    );
  }
}
