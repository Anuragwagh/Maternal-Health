enum UserRole {
  patient,
  asha,
  anm,
  supervisor,
  caregiver;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'asha':
        return UserRole.asha;
      case 'anm':
        return UserRole.anm;
      case 'supervisor':
        return UserRole.supervisor;
      case 'caregiver':
        return UserRole.caregiver;
      case 'patient':
      default:
        return UserRole.patient;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Mother (Patient)';
      case UserRole.asha:
        return 'ASHA Worker';
      case UserRole.anm:
        return 'ANM (Auxiliary Nurse Midwife)';
      case UserRole.supervisor:
        return 'PHC Supervisor';
      case UserRole.caregiver:
        return 'Caregiver / Family';
    }
  }
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String language;
  final String? phcId;
  final String? pinHash;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.language = 'en',
    this.phcId,
    this.pinHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role.name,
      'language': language,
      'phc_id': phcId,
      'pin_hash': pinHash,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: UserRole.fromString(map['role']?.toString() ?? 'patient'),
      language: map['language']?.toString() ?? 'en',
      phcId: map['phc_id']?.toString(),
      pinHash: map['pin_hash']?.toString(),
    );
  }
}
