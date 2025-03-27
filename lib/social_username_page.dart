import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data/model/social_profile.dart';
import 'data/service/social_lookup_service_new.dart';

class SocialUsernamePage extends StatefulWidget {
  const SocialUsernamePage({Key? key}) : super(key: key);

  @override
  State<SocialUsernamePage> createState() => _SocialUsernamePageState();
}

class _SocialUsernamePageState extends State<SocialUsernamePage> {
  final TextEditingController _usernameController = TextEditingController();
  final SocialLookupService _lookupService = SocialLookupService();

  List<SocialProfile> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _searchUsername() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _error = 'Please enter a username';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });

    try {
      final results = await _lookupService.checkAllPlatforms(username);

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          const Text(
            'Social Network Username Lookup',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check if a username exists across multiple social networks.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Search form
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter a username to search',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onSubmitted: (_) => _searchUsername(),
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _searchUsername,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ],

          const SizedBox(height: 24),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(
                        child: Text(
                          'Enter a username and click Search to check social networks',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    // Count found profiles
    final foundCount = _results.where((profile) => profile.exists).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Results for "${_usernameController.text}"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'Found: $foundCount / ${_results.length}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Note: Results are based on HTTP responses and may not be 100% accurate.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final profile = _results[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: profile.exists ? Colors.green.shade100 : null,
                child: ListTile(
                  leading: Icon(
                    profile.exists ? Icons.check_circle : Icons.cancel,
                    color: profile.exists ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    profile.platform,
                    style: TextStyle(
                      fontWeight:
                          profile.exists ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.error ?? profile.url,
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (profile.exists)
                        const Text(
                          'Tap to open, long press to copy URL',
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: profile.exists
                      ? IconButton(
                          icon: const Icon(Icons.open_in_new),
                          tooltip: 'Open in browser',
                          onPressed: () => _launchUrl(profile.url),
                        )
                      : null,
                  onTap: profile.exists ? () => _launchUrl(profile.url) : null,
                  onLongPress: profile.exists
                      ? () {
                          Clipboard.setData(ClipboardData(text: profile.url));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('URL copied to clipboard')),
                          );
                        }
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
