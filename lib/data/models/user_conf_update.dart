class UserConfUpdate {
  final Map<String, dynamic> data;

  const UserConfUpdate(this.data);

  Map<String, dynamic> toJson() => data;

  factory UserConfUpdate.single(String key, dynamic value) {
    return UserConfUpdate({key: value});
  }
}
