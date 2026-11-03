import 'package:flutter/material.dart';

import '../theme/mihrab_palette.dart';
import '../theme/mihrab_theme.dart';

/// Tappable surface with a clearly visible focus state, so it can be driven by
/// touch, mouse or a TV remote (D-pad + OK/Enter).
class FocusableCard extends StatefulWidget {
  const FocusableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = MihrabRadius.md,
    this.padding = EdgeInsets.zero,
    this.autofocus = false,
    this.selected = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool autofocus;

  /// Marks the card as the current choice (e.g. the active theme).
  final bool selected;
  final String? semanticLabel;

  @override
  State<FocusableCard> createState() => _FocusableCardState();
}

class _FocusableCardState extends State<FocusableCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final highlighted = _focused || widget.selected;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        autofocus: widget.autofocus,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _focused ? 1.03 : 1,
            duration: const Duration(milliseconds: 140),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: _focused
                    ? Color.alphaBlend(
                        p.accent.withValues(alpha: 0.16),
                        p.card,
                      )
                    : p.card,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: highlighted ? p.accent : p.cardBorder,
                  width: _focused ? 2.5 : (widget.selected ? 2 : 1),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
