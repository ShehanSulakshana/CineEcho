import 'package:flutter/material.dart';

Widget completedStatsCard(String watchTime, int movies, int episodes) {
  return IntrinsicHeight(
    child: Card(
      color: Color.fromARGB(255, 10, 40, 60),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _statColumnAnimated(
                Icons.timelapse,
                Colors.lightBlue,
                'Total WatchTime',
                watchTime,
              ),
            ),
            VerticalDivider(color: Colors.blue[700]!, thickness: 1),
            Expanded(
              child: _statColumnAnimated(
                Icons.movie,
                Colors.blue,
                'Movies',
                movies.toString(),
                isNumeric: true,
                numericValue: movies,
              ),
            ),
            VerticalDivider(color: Colors.blue[700]!, thickness: 1),
            Expanded(
              child: _statColumnAnimated(
                Icons.tv,
                Colors.lightBlue,
                'Tv Episodes',
                episodes.toString(),
                isNumeric: true,
                numericValue: episodes,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _statColumnAnimated(
  IconData icon,
  Color iconColor,
  String label,
  String value, {
  bool isNumeric = false,
  int numericValue = 0,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: iconColor, size: 28),
      SizedBox(height: 6),
      Text(label, style: TextStyle(color: Colors.white70, fontSize: 11)),
      if (isNumeric)
        _CountingNumber(end: numericValue)
      else if (label == 'Total WatchTime')
        _CountingTime(timeString: value)
      else
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
    ],
  );
}

class _CountingNumber extends StatefulWidget {
  final int end;

  const _CountingNumber({required this.end});

  @override
  State<_CountingNumber> createState() => _CountingNumberState();
}

class _CountingNumberState extends State<_CountingNumber>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = IntTween(
      begin: 0,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _CountingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.end != widget.end) {
      _controller.dispose();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

class _CountingTime extends StatefulWidget {
  final String timeString;

  const _CountingTime({required this.timeString});

  @override
  State<_CountingTime> createState() => _CountingTimeState();
}

class _CountingTimeState extends State<_CountingTime>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _hoursAnimation;
  late Animation<int> _minutesAnimation;

  late int _targetHours;
  late int _targetMinutes;

  @override
  void initState() {
    super.initState();
    _parseTimeString();
    _startAnimation();
  }

  void _parseTimeString() {
    final parts = widget.timeString.split(' ');
    _targetHours = 0;
    _targetMinutes = 0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].contains('h')) {
        _targetHours = int.tryParse(parts[i].replaceAll('h', '')) ?? 0;
      } else if (parts[i].contains('m')) {
        _targetMinutes = int.tryParse(parts[i].replaceAll('m', '')) ?? 0;
      }
    }
  }

  void _startAnimation() {
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _hoursAnimation = IntTween(
      begin: 0,
      end: _targetHours,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _minutesAnimation = IntTween(
      begin: 0,
      end: _targetMinutes,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _CountingTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeString != widget.timeString) {
      _controller.dispose();
      _parseTimeString();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoursAnimation, _minutesAnimation]),
      builder: (context, child) {
        return Text(
          '${_hoursAnimation.value}h ${_minutesAnimation.value}m',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
