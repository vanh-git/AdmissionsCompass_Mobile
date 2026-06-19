import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> slides = [
    {
      'icon': '🚀',
      'title': 'Chào mừng bạn!',
      'description':
          'Khám phá bản thân và định hướng tương lai ngay trên điện thoại của bạn.',
    },
    {
      'icon': '📝',
      'title': 'Trắc nghiệm RIASEC',
      'description':
          'Tìm hiểu tính cách nghề nghiệp phù hợp với sở thích và năng lực của bạn.',
    },
    {
      'icon': '💬',
      'title': 'Chat cộng đồng',
      'description':
          'Chia sẻ kinh nghiệm tuyển sinh và nhận lời khuyên từ cộng đồng.',
    },
    {
      'icon': '🔮',
      'title': 'Thần số học',
      'description':
          'Giải mã các con số gắn với ngày sinh và tên bạn để hiểu bản thân hơn.',
    },
    {
      'icon': '✨',
      'title': 'Hoàn toàn miễn phí',
      'description':
          'Ưu tiên trải nghiệm thân thiện, dễ sử dụng trên mọi thiết bị.',
    },
  ];

  void _goNext() {
    if (_currentIndex < slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B1326), Color(0xFF1E293B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: widget.onComplete,
                    child: const Text(
                      'Bỏ qua',
                      style: TextStyle(color: Color(0xFFB7C5FF)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(
                                  255,
                                  255,
                                  255,
                                  0.12,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                slide['icon']!,
                                style: const TextStyle(fontSize: 96),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              slide['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              slide['description']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFCAD2FF),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? const Color(0xFF9DFAFF)
                                  : const Color(0xFF4B5563),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _goNext,
                          child: Text(
                            _currentIndex == slides.length - 1
                                ? 'Bắt đầu ngay'
                                : 'Tiếp theo',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
