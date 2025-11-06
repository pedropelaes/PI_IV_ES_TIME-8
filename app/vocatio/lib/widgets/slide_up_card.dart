import 'package:flutter/material.dart';

class SlideUpContainer extends StatefulWidget{
  final List<Widget> content;
  final Duration animationDuration;
  final Curve animationCurve;
  final ThemeData theme;

  const SlideUpContainer({
    super.key,
    required this.content,
    required this.theme,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<SlideUpContainer> createState() => _SlideUpContainerState();
}

class _SlideUpContainerState extends State<SlideUpContainer> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.animationDuration);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animationController, curve: widget.animationCurve)
    );
    
    _animationController.forward();
  }

  @override void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            gradient: LinearGradient(
            colors: [widget.theme.colorScheme.onPrimaryFixed, widget.theme.colorScheme.onPrimaryFixedVariant],
            stops: [0, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        margin: EdgeInsets.only(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              spacing: 15,
              mainAxisSize: MainAxisSize.min,
              children: widget.content,
            ),
          ),
        ),
      ),
    );
  }
}