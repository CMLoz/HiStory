import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;
  final VoidCallback? onFinished;

  const TypewriterText(
    this.text, {
    super.key,
    required this.style,
    this.speed = const Duration(milliseconds: 30),
    this.onFinished,
  });

  @override
  State<TypewriterText> createState() => TypewriterTextState();
}

class TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;
  bool _isFinished = false;
  final AutoSizeGroup _autoSizeGroup = AutoSizeGroup();

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();
    _displayedText = '';
    _currentIndex = 0;
    _isFinished = false;

    if (widget.text.isEmpty) {
      _finishTyping();
      return;
    }

    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _finishTyping();
      }
    });
  }

  void _finishTyping() {
    _timer?.cancel();
    if (!_isFinished) {
      setState(() {
        _displayedText = widget.text;
        _currentIndex = widget.text.length;
        _isFinished = true;
      });
      widget.onFinished?.call();
    }
  }

  void completeText() {
    _finishTyping();
  }

  bool get isFinished => _isFinished;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.0,
          child: AutoSizeText(
            widget.text,
            style: widget.style,
            group: _autoSizeGroup,
            minFontSize: 8,
          ),
        ),
        AutoSizeText(
          _displayedText,
          style: widget.style,
          group: _autoSizeGroup,
          minFontSize: 8,
        ),
      ],
    );
  }
}
