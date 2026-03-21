class PasswordEntry {
  final int? id;
  final String title;
  final String username;
  final String password;

  PasswordEntry({
    this.id,
    required this.title,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
    );
  }
}
