class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime joinDate;
  final UserFinancialProfile financialProfile;
  final UserPreferences preferences;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.joinDate,
    required this.financialProfile,
    required this.preferences,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'joinDate': joinDate.toIso8601String(),
      'financialProfile': financialProfile.toJson(),
      'preferences': preferences.toJson(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      joinDate: DateTime.parse(json['joinDate']),
      financialProfile: UserFinancialProfile.fromJson(json['financialProfile']),
      preferences: UserPreferences.fromJson(json['preferences']),
    );
  }
}

class UserFinancialProfile {
  final double monthlyIncome;
  final double monthlySavingsGoal;
  final RiskTolerance riskTolerance;
  final List<String> financialGoals;
  final double emergencyFundTarget;
  final int retirementAge;

  UserFinancialProfile({
    required this.monthlyIncome,
    required this.monthlySavingsGoal,
    required this.riskTolerance,
    required this.financialGoals,
    required this.emergencyFundTarget,
    required this.retirementAge,
  });

  Map<String, dynamic> toJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'monthlySavingsGoal': monthlySavingsGoal,
      'riskTolerance': riskTolerance.name,
      'financialGoals': financialGoals,
      'emergencyFundTarget': emergencyFundTarget,
      'retirementAge': retirementAge,
    };
  }

  factory UserFinancialProfile.fromJson(Map<String, dynamic> json) {
    return UserFinancialProfile(
      monthlyIncome: json['monthlyIncome'].toDouble(),
      monthlySavingsGoal: json['monthlySavingsGoal'].toDouble(),
      riskTolerance: RiskTolerance.values.firstWhere(
        (e) => e.name == json['riskTolerance'],
      ),
      financialGoals: List<String>.from(json['financialGoals']),
      emergencyFundTarget: json['emergencyFundTarget'].toDouble(),
      retirementAge: json['retirementAge'],
    );
  }
}

class UserPreferences {
  final bool darkMode;
  final bool notificationsEnabled;
  final String currency;
  final String language;
  final bool biometricAuth;
  final List<String> favoriteCategories;

  UserPreferences({
    required this.darkMode,
    required this.notificationsEnabled,
    required this.currency,
    required this.language,
    required this.biometricAuth,
    required this.favoriteCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'currency': currency,
      'language': language,
      'biometricAuth': biometricAuth,
      'favoriteCategories': favoriteCategories,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'],
      notificationsEnabled: json['notificationsEnabled'],
      currency: json['currency'],
      language: json['language'],
      biometricAuth: json['biometricAuth'],
      favoriteCategories: List<String>.from(json['favoriteCategories']),
    );
  }
}

enum RiskTolerance { conservative, moderate, aggressive }
