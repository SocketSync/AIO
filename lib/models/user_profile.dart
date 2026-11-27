class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String username;
  final String bio;
  final String? avatarUrl;
  final String? phone;
  final String? occupation;
  final String currency;
  final double monthlyBudget;
  final String themePreference;
  final bool aiInsightsEnabled;
  final bool overspendingAlertsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.username = '',
    this.bio = '',
    this.avatarUrl,
    this.phone,
    this.occupation,
    this.currency = 'RM',
    this.monthlyBudget = 2500.00,
    this.themePreference = 'system',
    this.aiInsightsEnabled = true,
    this.overspendingAlertsEnabled = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? phone,
    String? occupation,
    String? currency,
    double? monthlyBudget,
    String? themePreference,
    bool? aiInsightsEnabled,
    bool? overspendingAlertsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      currency: currency ?? this.currency,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      themePreference: themePreference ?? this.themePreference,
      aiInsightsEnabled: aiInsightsEnabled ?? this.aiInsightsEnabled,
      overspendingAlertsEnabled:
          overspendingAlertsEnabled ?? this.overspendingAlertsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'username': username,
      'bio': bio,
      'avatar_url': avatarUrl,
      'phone': phone,
      'occupation': occupation,
      'currency': currency,
      'monthly_budget': monthlyBudget,
      'theme_preference': themePreference,
      'ai_insights_enabled': aiInsightsEnabled,
      'overspending_alerts_enabled': overspendingAlertsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? 'User',
      username: json['username'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      occupation: json['occupation'] as String?,
      currency: json['currency'] as String? ?? 'RM',
      monthlyBudget: (json['monthly_budget'] as num?)?.toDouble() ?? 2500.00,
      themePreference: json['theme_preference'] as String? ?? 'system',
      aiInsightsEnabled: json['ai_insights_enabled'] as bool? ?? true,
      overspendingAlertsEnabled:
          json['overspending_alerts_enabled'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

// AIO-76: User profile model.
