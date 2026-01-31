import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 25, 42),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About CineEcho',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withAlpha(77),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/splash/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'CineEcho',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ),
              SizedBox(height: 32),
              _buildSectionTitle('About'),
              SizedBox(height: 12),
              Text(
                'CineEcho is your personal entertainment tracker. Keep track of all the movies and TV shows you watch, manage your favorites, and view your viewing statistics at a glance.',
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 32),
              _buildSectionTitle('Features'),
              SizedBox(height: 12),
              _buildFeatureItem(
                'Track Watched Content',
                'Log every movie and TV episode you watch with automatic timestamps',
              ),
              SizedBox(height: 12),
              _buildFeatureItem(
                'Manage Favorites',
                'Create and organize your favorite movies and TV series',
              ),
              SizedBox(height: 12),
              _buildFeatureItem(
                'Viewing Statistics',
                'Animated stats showing total movies watched, episodes watched, and watch time',
              ),
              SizedBox(height: 12),
              _buildFeatureItem(
                'Detailed Content Info',
                'Browse cast details, episode information, and seasonal breakdowns',
              ),
              SizedBox(height: 12),
              _buildFeatureItem(
                'User Profile',
                'Personalize your profile with custom avatar and personal information',
              ),
              SizedBox(height: 12),
              _buildFeatureItem(
                'Easy Refresh',
                'Pull-to-refresh functionality to keep your data synchronized',
              ),
              SizedBox(height: 32),
              _buildSectionTitle('Feedback'),
              SizedBox(height: 12),
              Text(
                'We value your feedback! Share your thoughts, report issues, or suggest features through the feedback form in the menu.',
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 32),
              _buildSectionTitle('Contact'),
              SizedBox(height: 12),
              _buildContactLink(
                'Email',
                'shehansulakshana01@gmail.com',
                Icons.email_rounded,
                'mailto:shehansulakshana01@gmail.com',
              ),
              SizedBox(height: 16),
              _buildSocialLink(
                'GitHub',
                'https://github.com/ShehanSulakshana',
                Icons.code_rounded,
              ),
              SizedBox(height: 12),
              _buildSocialLink(
                'LinkedIn',
                'https://www.linkedin.com/in/shehan-sulakshana-129758342',
                Icons.business_rounded,
              ),
              SizedBox(height: 40),
              _buildPoweredBySection(),
              SizedBox(height: 32),
              Center(
                child: Text(
                  '© 2026 CineEcho. All rights reserved.',
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, color: Colors.lightBlue, size: 24),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withAlpha(153),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLink(String label, String url, IconData icon) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(77)),
          color: Colors.white.withAlpha(13),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.lightBlue, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactLink(
    String label,
    String value,
    IconData icon,
    String url,
  ) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(77)),
          color: Colors.white.withAlpha(13),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.lightBlue, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: Colors.white30, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPoweredBySection() {
    return Center(
      child: GestureDetector(
        onTap: () => _launchUrl('https://www.themoviedb.org'),
        child: Column(
          children: [
            Text(
              'Powered by',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(77)),
                color: Colors.white.withAlpha(13),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.themoviedb.org/assets/2/v4/logos/v2/blue_short-8e7b30f73a4020692ccca9c88bbb5ce5696210da5dbb3ead17b2fc7caccc848c.svg',
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'The Movie Database',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white30,
                    size: 14,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Data provided by The Movie Database (TMDB)',
              style: TextStyle(color: Colors.white30, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
