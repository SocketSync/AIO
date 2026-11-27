import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centers and constrains page content to the unified [AppTheme.maxContentWidth]
/// (`640.0`) with consistent responsive padding matching the FinWise Web Portal.
class ResponsivePageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final ScrollPhysics? physics;

  const ResponsivePageContainer({
    super.key,
    required this.child,
    this.maxWidth = AppTheme.maxContentWidth,
    this.padding,
    this.scrollable = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppTheme.pageHorizontalPadding,
                  vertical: AppTheme.pageVerticalPadding,
                ),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );

    if (!scrollable) return content;

    return SingleChildScrollView(
      physics: physics,
      child: content,
    );
  }
}
