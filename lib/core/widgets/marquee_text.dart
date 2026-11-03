import 'package:flutter/material.dart';

/// Single-line text that scrolls horizontally when it does not fit.
///
/// Scrolls right-to-left for LTR text and left-to-right for RTL text. Short
/// text is simply centred. The motion is driven by an animation controller
/// that is paused automatically when the widget is not visible.
class MarqueeText extends StatefulWidget {
  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.pixelsPerSecond = 60,
    this.gap = 80,
  });

  final String text;
  final TextStyle style;
  final double pixelsPerSecond;
  final double gap;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Stopwatch _clock = Stopwatch();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _clock.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: direction,
          maxLines: 1,
        )..layout();

        final textWidth = painter.width;
        final height = painter.height;
        final available = constraints.maxWidth;

        if (!available.isFinite || textWidth <= available) {
          return SizedBox(
            height: height,
            child: Center(
              child: Text(
                widget.text,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: widget.style,
              ),
            ),
          );
        }

        final cycle = textWidth + widget.gap;
        final sign = direction == TextDirection.rtl ? 1.0 : -1.0;

        Widget copy() => Text(
          widget.text,
          maxLines: 1,
          softWrap: false,
          style: widget.style,
        );

        return SizedBox(
          height: height,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final seconds = _clock.elapsedMilliseconds / 1000.0;
                final offset = (seconds * widget.pixelsPerSecond) % cycle;

                return OverflowBox(
                  alignment: AlignmentDirectional.centerStart,
                  minWidth: 0,
                  maxWidth: double.infinity,
                  child: Transform.translate(
                    offset: Offset(sign * offset, 0),
                    child: child,
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [copy(), SizedBox(width: widget.gap), copy()],
              ),
            ),
          ),
        );
      },
    );
  }
}
