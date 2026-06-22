import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  int? _number;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _calculate() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _dobController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy nhập họ tên và ngày sinh của bạn.')),
      );
      return;
    }
    final sum = name.toUpperCase().runes.fold<int>(
      0,
      (value, code) =>
          code >= 65 && code <= 90 ? value + ((code - 65) % 9) + 1 : value,
    );
    setState(() => _number = sum % 9 == 0 ? 9 : sum % 9);
  }

  String _meaning(int number) => const {
    1: 'Độc lập, chủ động và có tố chất dẫn dắt.',
    2: 'Tinh tế, biết lắng nghe và giàu tinh thần hợp tác.',
    3: 'Sáng tạo, giàu năng lượng và có khả năng truyền cảm hứng.',
    4: 'Kỷ luật, thực tế và đáng tin cậy.',
    5: 'Linh hoạt, yêu tự do và thích trải nghiệm.',
    6: 'Quan tâm, trách nhiệm và luôn muốn chăm sóc mọi người.',
    7: 'Sâu sắc, ham học hỏi và có tư duy phân tích.',
    8: 'Tham vọng, quyết đoán và có năng lực quản lý.',
    9: 'Nhân ái, lý tưởng và luôn hướng đến cộng đồng.',
  }[number]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khám phá thần số')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                AppCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 42),
                      SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Con số kể gì về bạn?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Một trải nghiệm vui để hiểu thêm về điểm mạnh và phong cách của chính mình.',
                              style: TextStyle(
                                color: Color(0xFFFCE7F3),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _dobController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh (dd/mm/yyyy)',
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _calculate,
                          icon: const Icon(Icons.bolt),
                          label: const Text('Khám phá ngay'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_number != null) ...[
                  const SizedBox(height: 18),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: 1),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: AppCard(
                      child: Column(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: const BoxDecoration(
                              gradient: AppColors.heroGradient,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$_number',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Con số nổi bật của bạn',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _meaning(_number!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
