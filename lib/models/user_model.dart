class UserModel {
  final String email;
  String uid, name, contactNo, department, joiningDate, profileImage, role;
  bool isActive;

  UserModel(
      {required this.uid,
      required this.email,
      required this.name,
      required this.contactNo,
      required this.department,
      required this.joiningDate,
      required this.profileImage,
      this.role = "user",
      this.isActive = true});

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "uid": uid,
      "name": name,
      "contactNo": contactNo,
      "department": department,
      "joiningDate": joiningDate,
      "profileImage": profileImage,
      "role": role,
      "isActive": isActive,
    };
  }
}
