class UserModel {
  String? emailAddress;
  String? password;
  String? confirmPassword;
  String? firstName;
  String? lastName;
  String? profileImage;

  UserModel({
    this.emailAddress,
    this.password,
    this.confirmPassword,
    this.firstName,
    this.lastName,
    this.profileImage
  });

  // Factory method to create a UserModel object from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      emailAddress: map['emailAddress'],
      password: map['password'],
      confirmPassword: map['confirmPassword'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      profileImage: map['profileImage']
    );
  }

  // Method to convert UserModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'emailAddress': emailAddress,
      'password': password,
      'confirmPassword': confirmPassword,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage':profileImage
    };
  }
}
