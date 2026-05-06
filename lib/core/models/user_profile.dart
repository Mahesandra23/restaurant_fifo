class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final int status; // 0 = Customer, 1 = Kitchen/Admin

  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.status,
  });

  // Fungsi pembantu untuk mengecek role
  bool get isKitchen => status == 1;
  bool get isCustomer => status == 0;
}