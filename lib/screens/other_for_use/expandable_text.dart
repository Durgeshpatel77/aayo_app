import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String content;
  final int wordLimit;
  final Color? textColor;
  final Color? linkColor;

  const ExpandableText({
    Key? key,
    required this.content,
    this.wordLimit = 20,
    this.textColor,
    this.linkColor,
  }) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final words = widget.content.trim().split(RegExp(r'\s+'));
    final isLongText = words.length > widget.wordLimit;

    String displayText = isExpanded
        ? widget.content
        : (isLongText
        ? words.take(widget.wordLimit).join(' ')
        : widget.content);

    final textColor = widget.textColor ?? Colors.black;
    final linkColor = widget.linkColor ?? Colors.pink;

    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: RichText(
        text: TextSpan(
          text: displayText,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          children: [
            if (isLongText && !isExpanded)
              TextSpan(
                text: '...read more',
                style: TextStyle(
                  fontSize: 14,
                  color: linkColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (isExpanded)
              TextSpan(
                text: ' ...show less',
                style: TextStyle(
                  fontSize: 14,
                  color: linkColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
