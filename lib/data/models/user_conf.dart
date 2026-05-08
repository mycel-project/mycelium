class UserConf {
  final Map<String, dynamic> data;

  const UserConf(this.data);

  factory UserConf.fromJson(Map<String, dynamic> json) {
    return UserConf(json);
  }

  Map<String, dynamic> toJson() => data;

  dynamic get(String key) => data[key];
}
