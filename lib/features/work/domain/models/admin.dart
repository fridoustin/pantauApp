class Admin {
  final String id;
  final String name;
  final String? email;

  const Admin({
    required this.id,
    required this.name,
    this.email,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['admin_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': id,
      'name': name,
      'email': email,
    };
  }
}