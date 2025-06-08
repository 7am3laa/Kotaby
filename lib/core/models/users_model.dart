class UsersModel {
  final int id;
  final String userName;
  final String password;
  final String email;
  final String? image; // جعلها nullable
  final DateTime? dateOfBirth;
  final String? nationality;

  UsersModel({
    required this.id,
    required this.userName,
    required this.password,
    required this.email,
    this.image,
    this.dateOfBirth,
    this.nationality,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['id'],
      userName: json['userName'],
      password: json['password'],
      email: json['email'],
      image: json['image'], // قد تكون null
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      nationality: json['nationality'],
    );
  }

  UsersModel copyWith({
    int? id,
    String? userName,
    String? password,
    String? email,
    String? image,
    DateTime? dateOfBirth,
    String? nationality,
  }) {
    return UsersModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      email: email ?? this.email,
      image: image ?? this.image,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
    );
  }
}