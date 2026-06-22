import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../context/auth_provider.dart';
import '../data/riasec_questions.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onStartTest;
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenNumerology;

  const HomeScreen({
    super.key,
    this.onStartTest,
    this.onOpenChat,
    this.onOpenNumerology,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, int>? _results;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final value = (await SharedPreferences.getInstance()).getString(
      'riasecResults',
    );
    if (value == null || !mounted) return;
    final decoded = jsonDecode(value) as Map<String, dynamic>;
    setState(
      () => _results = decoded.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name =
        auth.user?.displayName ?? auth.user?.email?.split('@').first ?? 'Bạn';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(name),
                  const SizedBox(height: 24),
                  const Text(
                    'Khám phá bản thân',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Những công cụ nhỏ giúp bạn đưa ra lựa chọn lớn.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 720;
                      final cards = [
                        _featureCard(
                          icon: Icons.explore_rounded,
                          eyebrow: 'ĐỊNH HƯỚNG NGHỀ NGHIỆP',
                          title: 'Trắc nghiệm RIASEC',
                          description:
                              'Khám phá nhóm tính cách, Holland Code và ngành học phù hợp.',
                          colors: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          action: 'Làm bài ngay',
                          onTap: widget.onStartTest,
                        ),
                        _featureCard(
                          icon: Icons.forum_rounded,
                          eyebrow: 'KẾT NỐI & CHIA SẺ',
                          title: 'Cộng đồng tuyển sinh',
                          description:
                              'Hỏi đáp, chia sẻ kinh nghiệm và học cùng những người bạn mới.',
                          colors: const [Color(0xFF0284C7), Color(0xFF06B6D4)],
                          action: 'Vào cộng đồng',
                          onTap: widget.onOpenChat,
                        ),
                        _featureCard(
                          icon: Icons.auto_awesome,
                          eyebrow: 'HIỂU MÌNH HƠN',
                          title: 'Khám phá thần số',
                          description:
                              'Một góc nhìn vui và thú vị về điểm mạnh trong tính cách của bạn.',
                          colors: const [Color(0xFFF97316), Color(0xFFEC4899)],
                          action: 'Khám phá ngay',
                          onTap: widget.onOpenNumerology,
                        ),
                      ];
                      if (!wide) {
                        return Column(
                          children: cards
                              .map(
                                (card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cards
                            .map(
                              (card) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: card,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  if (_results != null) ...[
                    const SizedBox(height: 24),
                    _recentResult(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(String name) {
    return AppCard(
      gradient: AppColors.heroGradient,
      padding: const EdgeInsets.all(26),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0x22FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, $name 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hôm nay bạn muốn khám phá điều gì về tương lai?',
                      style: TextStyle(color: Color(0xFFE0E7FF), height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String eyebrow,
    required String title,
    required String description,
    required List<Color> colors,
    required String action,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 18 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.first.withAlpha(45),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 34),
              const SizedBox(height: 24),
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(color: Color(0xDFFFFFFF), height: 1.45),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentResult() {
    final sorted = _results!.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AppColors.primary),
              SizedBox(width: 10),
              Text(
                'Kết quả RIASEC gần đây',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sorted.take(3).map((entry) {
            final type = RIASECType.values.firstWhere(
              (item) => item.name == entry.key,
            );
            final label = riasecLabels[type]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(label.icon, style: const TextStyle(fontSize: 25)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${type.name} • ${label.name}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: entry.value / 40,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: const Color(0xFFE2E8F0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.value}/40',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
