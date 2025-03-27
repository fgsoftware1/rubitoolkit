import 'dart:async';
import 'package:http/http.dart' as http;
import '../model/social_profile.dart';

class SocialLookupService {
  static const timeout = Duration(seconds: 10);

  // List of social platforms with their URL patterns
  static final List<Map<String, String>> platforms = [
    {'name': 'Twitter/X', 'url': 'https://x.com/'},
    {'name': 'Instagram', 'url': 'https://www.instagram.com/'},
    {'name': 'Facebook', 'url': 'https://www.facebook.com/'},
    {'name': 'GitHub', 'url': 'https://github.com/'},
    {'name': 'LinkedIn', 'url': 'https://www.linkedin.com/in/'},
    {'name': 'Reddit', 'url': 'https://www.reddit.com/user/'},
    {'name': 'TikTok', 'url': 'https://www.tiktok.com/@'},
    {'name': 'YouTube', 'url': 'https://www.youtube.com/@'},
    {'name': 'Pinterest', 'url': 'https://www.pinterest.com/'},
    {'name': 'Twitch', 'url': 'https://www.twitch.tv/'},
    {'name': 'Medium', 'url': 'https://medium.com/@'},
    {'name': 'Tumblr', 'url': 'https://www.tumblr.com/blog/view/'},
    {'name': 'Mastodon', 'url': 'https://mastodon.social/@'},
    {'name': 'Quora', 'url': 'https://www.quora.com/profile/'},
    {'name': 'Snapchat', 'url': 'https://www.snapchat.com/add/'},
  ];

  // Check if a username exists on a social platform
  Future<SocialProfile> checkUsername(
      String platform, String url, String username) async {
    final fullUrl = url + username;

    try {
      // Add a User-Agent header to mimic a browser request
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        },
      ).timeout(timeout);

      // Check for redirects - many platforms redirect non-existent profiles
      final finalUrl = response.request?.url.toString() ?? fullUrl;
      final wasRedirected = finalUrl != fullUrl;

      // Check for common "not found" indicators in the response body
      final bodyLowerCase = response.body.toLowerCase();
      final containsNotFoundIndicators = bodyLowerCase.contains('not found') ||
          bodyLowerCase.contains('doesn\'t exist') ||
          bodyLowerCase.contains('page not found') ||
          bodyLowerCase.contains('no results found') ||
          bodyLowerCase.contains('404');

      // Determine if the profile exists based on status code, redirects, and content
      final exists = response.statusCode == 200 &&
          !wasRedirected &&
          !containsNotFoundIndicators;

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
      return SocialProfile.error(platform, fullUrl, e.toString());
    }
  }

  // Check username across all platforms
  Future<List<SocialProfile>> checkAllPlatforms(String username) async {
    List<SocialProfile> results = [];

    // Process platforms sequentially with a delay to avoid rate limiting
    for (var platform in platforms) {
      final result =
          await checkUsername(platform['name']!, platform['url']!, username);
      results.add(result);

      // Add a small delay between requests to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }
}
