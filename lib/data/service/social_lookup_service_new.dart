import 'dart:async';
import 'package:http/http.dart' as http;
import '../model/social_profile.dart';

class SocialLookupService {
  static const timeout = Duration(seconds: 10);

  // List of social platforms with their URL patterns
  static final List<Map<String, dynamic>> platforms = [
    {
      'name': 'Twitter/X',
      'url': 'https://x.com/',
      'errorCodes': [400, 404],
    },
    {
      'name': 'Instagram',
      'url': 'https://www.instagram.com/',
      'errorCodes': [404],
    },
    {
      'name': 'Facebook',
      'url': 'https://www.facebook.com/',
      'errorCodes': [404],
    },
    {
      'name': 'GitHub',
      'url': 'https://github.com/',
      'errorCodes': [404],
    },
    {
      'name': 'LinkedIn',
      'url': 'https://www.linkedin.com/in/',
      'errorCodes': [404, 999],
    },
    {
      'name': 'Reddit',
      'url': 'https://www.reddit.com/user/',
      'errorCodes': [404],
    },
    {
      'name': 'TikTok',
      'url': 'https://www.tiktok.com/@',
      'errorCodes': [404],
    },
    {
      'name': 'YouTube',
      'url': 'https://www.youtube.com/@',
      'errorCodes': [404],
    },
    {
      'name': 'Pinterest',
      'url': 'https://www.pinterest.com/',
      'errorCodes': [404],
    },
    {
      'name': 'Twitch',
      'url': 'https://www.twitch.tv/',
      'errorCodes': [404],
    },
    {
      'name': 'Medium',
      'url': 'https://medium.com/@',
      'errorCodes': [404],
    },
    {
      'name': 'Tumblr',
      'url': 'https://www.tumblr.com/blog/view/',
      'errorCodes': [404],
    },
    {
      'name': 'Mastodon',
      'url': 'https://mastodon.social/@',
      'errorCodes': [404],
    },
    {
      'name': 'Quora',
      'url': 'https://www.quora.com/profile/',
      'errorCodes': [404],
    },
    {
      'name': 'Snapchat',
      'url': 'https://www.snapchat.com/add/',
      'errorCodes': [404],
    },
  ];

  // Check if a username exists on a social platform
  Future<SocialProfile> checkUsername(String platform, String url,
      String username, List<int> errorCodes) async {
    final fullUrl = url + username;

    try {
      // Use a GET request since some platforms don't support HEAD
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      ).timeout(timeout);

      // If the status code is in the error codes list, the profile doesn't exist
      final exists = !errorCodes.contains(response.statusCode);

      if (exists) {
        return SocialProfile(
          platform: platform,
          url: fullUrl,
          exists: true,
        );
      } else {
        return SocialProfile.notFound(platform, fullUrl);
      }
    } catch (e) {
      // For some platforms, an exception might indicate that the profile doesn't exist
      return SocialProfile.error(platform, fullUrl, e.toString());
    }
  }

  // Check username across all platforms
  Future<List<SocialProfile>> checkAllPlatforms(String username) async {
    List<SocialProfile> results = [];

    // Process platforms sequentially with a delay to avoid rate limiting
    for (var platform in platforms) {
      try {
        final result = await checkUsername(
          platform['name'],
          platform['url'],
          username,
          List<int>.from(platform['errorCodes'] ?? [404]),
        );
        results.add(result);
      } catch (e) {
        results.add(SocialProfile.error(
            platform['name'], platform['url'] + username, e.toString()));
      }

      // Add a small delay between requests to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }
}
