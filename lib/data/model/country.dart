class Country {
  final String name;
  final String code;
  final String flagEmoji;
  final String flagUrl;

  Country({
    required this.name,
    required this.code,
    required this.flagEmoji,
    required this.flagUrl,
  });

  /// Creates a Country object from JSON data
  factory Country.fromJson(Map<String, dynamic> json) {
    final countryCode = json['country_code'] ?? 'XX';
    return Country(
      name: json['name'] ?? 'Unknown',
      code: countryCode,
      flagEmoji: countryCodeToEmoji(countryCode),
      flagUrl: json['flag'] ?? generateFlagUrl(countryCode),
    );
  }

  /// Creates a default unknown country
  factory Country.unknown() {
    return Country(
      name: 'Unknown',
      code: 'XX',
      flagEmoji: '🏳️',
      flagUrl: generateFlagUrl('xx'),
    );
  }

  /// Generate a flag URL from a country code
  static String generateFlagUrl(String countryCode) {
    return 'https://flagcdn.com/w320/${countryCode.toLowerCase()}.png';
  }

  /// Convert country code to emoji flag
  static String countryCodeToEmoji(String countryCode) {
    // Handle invalid country codes
    if (countryCode.length != 2) return '🏳️';

    // Ensure uppercase for consistent calculation
    final upperCode = countryCode.toUpperCase();

    try {
      // Convert each letter to the corresponding regional indicator symbol
      final int firstLetter = upperCode.codeUnitAt(0) - 65 + 0x1F1E6;
      final int secondLetter = upperCode.codeUnitAt(1) - 65 + 0x1F1E6;

      return String.fromCharCode(firstLetter) +
          String.fromCharCode(secondLetter);
    } catch (e) {
      return '🏳️';
    }
  }
}
