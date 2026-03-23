class PasswordEntry {
  final int? id;
  final String title;
  final String username;
  final String password;
  final String category; // 'general', 'bank', 'social', 'work', 'other'
  final String? profilePassword; // Extra field for bank category (e.g., ATM PIN / profile password)
  final String? notes;

  PasswordEntry({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.category = 'general',
    this.profilePassword,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'category': category,
      'profilePassword': profilePassword,
      'notes': notes,
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
      category: map['category'] ?? 'general',
      profilePassword: map['profilePassword'],
      notes: map['notes'],
    );
  }

  PasswordEntry copyWith({
    int? id,
    String? title,
    String? username,
    String? password,
    String? category,
    String? profilePassword,
    String? notes,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      profilePassword: profilePassword ?? this.profilePassword,
      notes: notes ?? this.notes,
    );
  }
}
