import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/feedback_repository.dart';
import '../providers/auth_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late TextEditingController _subjectController;
  late TextEditingController _messageController;
  String _selectedType = 'Bug Report';
  bool _isSubmitting = false;
  Duration? _rateLimitRemaining;
  Timer? _rateLimitTimer;

  final List<String> _feedbackTypes = [
    'Bug Report',
    'Feature Request',
    'Suggestion',
    'General Feedback',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController();
    _messageController = TextEditingController();
    _checkRateLimit();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _rateLimitTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkRateLimit() async {
    try {
      final repo = FeedbackRepository();
      final remaining = await repo.getTimeUntilNextFeedback();
      if (mounted) {
        setState(() => _rateLimitRemaining = remaining);
        if (remaining.inSeconds > 0) {
          _startRateLimitTimer(remaining);
        }
      }
    } catch (e) {
      // Silently handle rate limit check errors
    }
  }

  void _startRateLimitTimer(Duration duration) {
    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_rateLimitRemaining != null &&
              _rateLimitRemaining!.inSeconds > 0) {
            _rateLimitRemaining = Duration(
              seconds: _rateLimitRemaining!.inSeconds - 1,
            );
          } else {
            _rateLimitTimer?.cancel();
            _rateLimitRemaining = null;
          }
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _submitFeedback() async {
    if (!_validateForm()) return;

    if (_rateLimitRemaining != null && _rateLimitRemaining!.inSeconds > 0) {
      _showErrorDialog(
        'Please wait ${_formatDuration(_rateLimitRemaining!)} before submitting another feedback',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthenticationProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        _showErrorDialog('Not logged in');
        return;
      }

      final repo = FeedbackRepository();
      await repo.submitFeedback(
        userName: user.displayName ?? 'Anonymous',
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        feedbackType: _selectedType,
      );

      if (!mounted) return;

      _showSuccessDialog();
      _subjectController.clear();
      _messageController.clear();
      setState(() => _selectedType = 'Bug Report');
      _checkRateLimit();
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().contains('wait')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Failed to submit feedback. Please try again.';
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateForm() {
    if (_subjectController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a subject');
      return false;
    }
    if (_messageController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your feedback message');
      return false;
    }
    if (_subjectController.text.trim().length < 5) {
      _showErrorDialog('Subject must be at least 5 characters');
      return false;
    }
    if (_messageController.text.trim().length < 10) {
      _showErrorDialog('Message must be at least 10 characters');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 0, 25, 42),
        title: Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(
          message,
          style: TextStyle(color: Colors.white.withAlpha(204)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 0, 25, 42),
        title: Text('Thank You!', style: TextStyle(color: Colors.white)),
        content: Text(
          'Your feedback has been submitted successfully.',
          style: TextStyle(color: Colors.white.withAlpha(204)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
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
          'Send Feedback',
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
              Text(
                'Help us improve CineEcho',
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 24),
              _buildLabel('Feedback Type'),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(77)),
                ),
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  underline: SizedBox(),
                  dropdownColor: const Color.fromARGB(255, 20, 40, 55),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  items: _feedbackTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() => _selectedType = value ?? 'Bug Report');
                        },
                ),
              ),
              SizedBox(height: 24),
              _buildLabel('Subject'),
              SizedBox(height: 8),
              TextField(
                controller: _subjectController,
                enabled: !_isSubmitting,
                style: TextStyle(color: Colors.white, fontSize: 15),
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'Brief subject of your feedback',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                  filled: true,
                  fillColor: Colors.white.withAlpha(13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(77)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(77)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  counterStyle: TextStyle(color: Colors.white30),
                ),
              ),
              SizedBox(height: 24),
              _buildLabel('Message'),
              SizedBox(height: 8),
              TextField(
                controller: _messageController,
                enabled: !_isSubmitting,
                style: TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 8,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText:
                      'Tell us more about your feedback or bug. The more details, the better!',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                  filled: true,
                  fillColor: Colors.white.withAlpha(13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(77)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(77)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  counterStyle: TextStyle(color: Colors.white30),
                ),
              ),
              SizedBox(height: 32),
              if (_rateLimitRemaining != null &&
                  _rateLimitRemaining!.inSeconds > 0)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orange.withAlpha(26),
                    border: Border.all(color: Colors.orange.withAlpha(128)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rate Limited',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Next feedback available in ${_formatDuration(_rateLimitRemaining!)}',
                              style: TextStyle(
                                color: Colors.orange.withAlpha(200),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_rateLimitRemaining != null &&
                  _rateLimitRemaining!.inSeconds > 0)
                SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Theme.of(
                      context,
                    ).primaryColor.withAlpha(128),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Submit Feedback',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'We read every feedback and continuously improve CineEcho',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
