import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const slides = [
    (
      Icons.rocket_launch_rounded,
      'Khởi đầu hành trình',
      'Khám phá bản thân và định hướng tương lai bằng những công cụ dễ hiểu, gần gũi.',
      Color(0xFF4F46E5),
    ),
    (
      Icons.explore_rounded,
      'Tìm ngành phù hợp',
      'Trắc nghiệm RIASEC giúp bạn hiểu sở thích nghề nghiệp và nhóm tính cách nổi bật.',
      Color(0xFF7C3AED),
    ),
    (
      Icons.forum_rounded,
      'Không đi một mình',
      'Trò chuyện, hỏi đáp và chia sẻ kinh nghiệm cùng cộng đồng học sinh – sinh viên.',
      Color(0xFF0284C7),
    ),
    (
      Icons.auto_awesome,
      'Hiểu mình hơn mỗi ngày',
      'Những trải nghiệm thú vị giúp bạn nhìn ra điểm mạnh và thêm tự tin với lựa chọn của mình.',
      Color(0xFFF97316),
    ),
  ];

  void _next() {
    if (_index == slides.length - 1) {
      widget.onComplete();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            key: ValueKey(index),
                            tween: Tween(begin: 0.75, end: 1),
                            duration: const Duration(milliseconds: 550),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: Container(
                              width: 164,
                              height: 164,
                              decoration: BoxDecoration(
                                color: const Color(0x22FFFFFF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0x44FFFFFF),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 40,
                                    offset: Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Icon(
                                slide.$1,
                                size: 74,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 38),
                          Text(
                            slide.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide.$3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFE0E7FF),
                              fontSize: 16,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        slides.length,
                        (item) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: item == _index ? 28 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: item == _index
                                ? Colors.white
                                : const Color(0x55FFFFFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text(
                          _index == slides.length - 1
                              ? 'Bắt đầu khám phá'
                              : 'Tiếp theo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
