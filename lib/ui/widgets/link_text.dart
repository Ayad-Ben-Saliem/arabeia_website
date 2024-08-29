import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkText extends StatelessWidget {
  final String text;
  final Uri uri;
  final Color color;
  final TextStyle? style;

  LinkText(
    this.text, {
    super.key,
    required String url,
    this.color = Colors.red,
    this.style,
  }) : uri = Uri.parse(url);

  void _launchURL() async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchURL,
      child: Text(
        text,
        style: style?.copyWith(
              color: style?.color ?? color,
              decoration: style?.decoration ?? TextDecoration.underline,
            ) ??
            TextStyle(
              color: color,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }
}
