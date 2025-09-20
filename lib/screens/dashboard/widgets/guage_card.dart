import 'package:flutter/material.dart';

class AnimatedGaugeCard extends StatefulWidget {
  final String title;
  final double value;
  final double max;
  final Color color;
  final Color bg;
  final String caption;

  const AnimatedGaugeCard({
    super.key,
    required this.title,
    required this.value,
    required this.max,
    required this.color,
    required this.bg,
    required this.caption,
  });

  @override
  State<AnimatedGaugeCard> createState() => AnimatedGaugeCardState();
}

class AnimatedGaugeCardState extends State<AnimatedGaugeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _anim = CurvedAnimation(parent: _ac, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = (widget.value / (widget.max == 0 ? 1 : widget.max))
        .clamp(0, 1.0)
        .toDouble();
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 0
            ? (constraints.maxWidth * 0.6).clamp(120.0, 180.0)
            : 160.0;
        final gaugeSize = (cardWidth * 0.6).clamp(70.0, 100.0);

        return Container(
          width: cardWidth,
          height: 180,
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ScaleTransition(
                scale: _anim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: gaugeSize,
                      height: gaugeSize,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                        backgroundColor: Colors.white12,
                      ),
                    ),
                    Text(
                      '${widget.value.toInt()}${widget.caption}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: Colors.white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
