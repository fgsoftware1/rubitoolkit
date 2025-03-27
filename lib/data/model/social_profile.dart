class SocialProfile {
  final String platform;
  final String url;
  final bool exists;
  final String? error;
  final String? avatarUrl;
  final String? displayName;
  final String? bio;

  SocialProfile({
    required this.platform,
    required this.url,
    required this.exists,
    this.error,
    this.avatarUrl,
    this.displayName,
    this.bio,
  });

  factory SocialProfile.notFound(String platform, String url) {
    return SocialProfile(
      platform: platform,
      url: url,
      exists: false,
    );
  }

  factory SocialProfile.error(String platform, String url, String errorMessage) {
    return SocialProfile(
      platform: platform,
      url: url,
      exists: false,
      error: errorMessage,
    );
  }
}