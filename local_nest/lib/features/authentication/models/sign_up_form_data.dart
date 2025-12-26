/// Form data model for sign up
class SignUpFormData {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final bool agreeToTerms;

  const SignUpFormData({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.agreeToTerms = false,
  });

  SignUpFormData copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    bool? agreeToTerms,
  }) {
    return SignUpFormData(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
    );
  }
}