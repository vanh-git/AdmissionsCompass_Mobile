import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../context/auth_provider.dart';
import '../data/numerology_profiles.dart';
import '../models/numerology_profile.dart';
import '../services/numerology_credit_service.dart';
import '../services/numerology_service.dart';

class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final _nameController = TextEditingController();
  final _creditService = NumerologyCreditService();
  DateTime? _birthDate;
  NumerologyResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );
    if (selected != null) setState(() => _birthDate = selected);
  }

  Future<void> _analyze() async {
    final user = context.read<AuthProvider>().user;
    final name = _nameController.text.trim();
    if (user == null) {
      _showMessage('Bạn cần đăng nhập để sử dụng tính năng này.');
      return;
    }
    if (name.length < 2 || _birthDate == null) {
      _showMessage('Hãy nhập họ tên và chọn ngày sinh hợp lệ.');
      return;
    }

    setState(() => _loading = true);
    try {
      final hasCredit = await _creditService.consumeCredit(user.uid);
      if (!hasCredit) {
        if (!mounted) return;
        final paid = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _PaywallSheet(uid: user.uid, service: _creditService),
        );
        if (paid != true) return;
      }
      if (!mounted) return;
      setState(() {
        _result = NumerologyService.calculate(name, _birthDate!);
      });
    } catch (error) {
      _showMessage('Không thể mở phân tích. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFF080515),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080515),
        foregroundColor: Colors.white,
        title: const Text(
          'Bản đồ thần số học',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (user != null)
            StreamBuilder<int>(
              stream: _creditService.watchCredits(user.uid),
              builder: (context, snapshot) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  avatar: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFFFBBF24),
                  ),
                  label: Text('${snapshot.data ?? 0} lượt'),
                  backgroundColor: const Color(0xFF21143C),
                  labelStyle: const TextStyle(color: Color(0xFFE9D5FF)),
                  side: const BorderSide(color: Color(0x554C1D95)),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _CosmicBackground()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: _result == null ? _inputView() : _resultView(_result!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 40),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, value, child) =>
                Transform.scale(scale: value, child: child),
            child: const _MysticOrb(),
          ),
          const SizedBox(height: 22),
          const Text(
            'GIẢI MÃ BẢN ĐỒ LINH HỒN',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 12,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Thần Số Học\nToàn Diện',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Khám phá 6 chỉ số từ ngày sinh và họ tên, bao gồm các số chủ đạo 11, 22 và 33.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFB8A8D8), height: 1.5),
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xCC100922),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0x554C1D95)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44000000),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  decoration: _cosmicInput(
                    'Họ và tên đầy đủ',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: _cosmicInput('Ngày sinh', Icons.calendar_month),
                    child: Text(
                      _birthDate == null
                          ? 'Chạm để chọn ngày'
                          : '${_birthDate!.day.toString().padLeft(2, '0')}/'
                                '${_birthDate!.month.toString().padLeft(2, '0')}/'
                                '${_birthDate!.year}',
                      style: TextStyle(
                        color: _birthDate == null
                            ? const Color(0xFF8576A5)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _analyze,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _loading ? 'Đang giải mã...' : 'Xem phân tích chi tiết',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6D28D9),
                      padding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mỗi lần xem chi tiết sử dụng 1 credit',
                  style: TextStyle(color: Color(0xFF8576A5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _cosmicInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFB8A8D8)),
      prefixIcon: Icon(icon, color: const Color(0xFFC9A84C)),
      filled: true,
      fillColor: const Color(0xFF160D2B),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x664C1D95)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
      ),
    );
  }

  Widget _resultView(NumerologyResult result) {
    final profile = numerologyProfiles[result.lifePath]!;
    final numbers = [
      ('Đường đời', result.lifePath, Icons.route),
      ('Ngày sinh', result.birthday, Icons.cake_outlined),
      ('Thái độ', result.attitude, Icons.wb_sunny_outlined),
      ('Sứ mệnh', result.destiny, Icons.explore_outlined),
      ('Linh hồn', result.soulUrge, Icons.favorite_outline),
      ('Nhân cách', result.personality, Icons.face_outlined),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
      child: Column(
        children: [
          _ResultHero(profile: profile, fullName: result.fullName),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth > 650
                  ? (constraints.maxWidth - 24) / 3
                  : (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: numbers
                    .map(
                      (item) => SizedBox(
                        width: width,
                        child: _NumberCard(
                          title: item.$1,
                          number: item.$2,
                          icon: item.$3,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          _detailCard('Bản chất cốt lõi', profile.essence, Icons.psychology),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _detailCard(
                  'Góc sáng',
                  profile.lightSide,
                  Icons.light_mode_outlined,
                  color: const Color(0xFF4ADE80),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _detailCard(
                  'Góc tối',
                  profile.darkSide,
                  Icons.dark_mode_outlined,
                  color: const Color(0xFFFB7185),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _listCard(
            'Điểm mạnh',
            profile.strengths,
            Icons.bolt,
            const Color(0xFFFBBF24),
          ),
          const SizedBox(height: 12),
          _listCard(
            'Điểm cần phát triển',
            profile.weaknesses,
            Icons.trending_up,
            const Color(0xFFF472B6),
          ),
          const SizedBox(height: 12),
          _detailCard('Môi trường lý tưởng', profile.workEnv, Icons.apartment),
          const SizedBox(height: 12),
          _chipsCard('Nghề nghiệp gợi ý', profile.careers),
          const SizedBox(height: 12),
          _chipsCard('Ngành học phù hợp', profile.majors),
          const SizedBox(height: 12),
          _detailCard('Bài học cuộc đời', profile.lesson, Icons.menu_book),
          const SizedBox(height: 12),
          _detailCard(
            'Lời khuyên dành cho bạn',
            profile.advice,
            Icons.tips_and_updates,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => setState(() => _result = null),
            icon: const Icon(Icons.refresh),
            label: const Text('Xem bản đồ khác'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE9D5FF),
              side: const BorderSide(color: Color(0x667C3AED)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard(
    String title,
    String content,
    IconData icon, {
    Color color = const Color(0xFFC4B5FD),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _resultDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(color: Color(0xFFDDD6FE), height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _listCard(
    String title,
    List<String> values,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _resultDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...values.map(
            (value) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                '• $value',
                style: const TextStyle(color: Color(0xFFDDD6FE), height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipsCard(String title, List<String> values) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _resultDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFBBF24),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map(
                  (value) => Chip(
                    label: Text(value),
                    backgroundColor: const Color(0xFF281844),
                    labelStyle: const TextStyle(color: Color(0xFFE9D5FF)),
                    side: const BorderSide(color: Color(0x554C1D95)),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  BoxDecoration _resultDecoration() => BoxDecoration(
    color: const Color(0xCC100922),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0x334C1D95)),
  );
}

class _PaywallSheet extends StatefulWidget {
  final String uid;
  final NumerologyCreditService service;

  const _PaywallSheet({required this.uid, required this.service});

  @override
  State<_PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<_PaywallSheet> {
  PaymentOrder? _order;
  StreamSubscription<String>? _statusSubscription;
  Timer? _timer;
  int _seconds = 300;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _create(CreditPackage package) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await widget.service.createPayment(
        uid: widget.uid,
        package: package,
      );
      if (!mounted) return;
      setState(() {
        _order = order;
        _seconds = 300;
      });
      _statusSubscription = widget.service
          .watchPaymentStatus(order.orderCode)
          .listen((status) {
            if (status == 'PAID' && mounted) Navigator.pop(context, true);
          });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _seconds <= 0) {
          timer.cancel();
        } else {
          setState(() => _seconds--);
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF100922),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: _order == null ? _packages() : _qrView(),
        ),
      ),
    );
  }

  Widget _packages() {
    return Column(
      children: [
        Container(
          width: 46,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 22),
        const Icon(Icons.auto_awesome, color: Color(0xFFFBBF24), size: 42),
        const SizedBox(height: 10),
        const Text(
          'Mở khóa bản đồ linh hồn',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Chọn gói lượt xem phù hợp với hành trình của bạn.',
          style: TextStyle(color: Color(0xFFB8A8D8)),
        ),
        const SizedBox(height: 20),
        ...NumerologyCreditService.packages.map(
          (package) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _loading ? null : () => _create(package),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1032),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x554C1D95)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF6D28D9),
                      child: Text(
                        '${package.credits}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${package.credits} lượt phân tích',
                            style: const TextStyle(color: Color(0xFFB8A8D8)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${package.priceVnd ~/ 1000}.000₫',
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(14),
            child: CircularProgressIndicator(),
          ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Color(0xFFFB7185))),
      ],
    );
  }

  Widget _qrView() {
    final order = _order!;
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return Column(
      children: [
        const Text(
          'Quét mã VietQR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${order.amount ~/ 1000}.000₫ • +${order.credits} lượt',
          style: const TextStyle(
            color: Color(0xFFFBBF24),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: QrImageView(data: order.qrCode, size: 240),
        ),
        const SizedBox(height: 14),
        Text(
          'Mã hết hạn sau $minutes:$seconds',
          style: const TextStyle(color: Color(0xFFB8A8D8)),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(order.checkoutUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Mở trang thanh toán PayOS'),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ứng dụng sẽ tự mở khóa khi webhook xác nhận thanh toán.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF8576A5), fontSize: 12),
        ),
      ],
    );
  }
}

class _NumberCard extends StatelessWidget {
  final String title;
  final int number;
  final IconData icon;

  const _NumberCard({
    required this.title,
    required this.number,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC100922),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x334C1D95)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC4B5FD)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFB8A8D8),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
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

class _ResultHero extends StatelessWidget {
  final NumerologyProfile profile;
  final String fullName;

  const _ResultHero({required this.profile, required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(profile.emoji, style: const TextStyle(fontSize: 42)),
          const SizedBox(height: 8),
          Text(
            '${profile.number}',
            style: const TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 70,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$fullName • ${profile.keyword}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFE9D5FF), height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _MysticOrb extends StatelessWidget {
  const _MysticOrb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFBBF24), Color(0xFF7C3AED), Color(0xFF100922)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x887C3AED), blurRadius: 50, spreadRadius: 6),
        ],
        border: Border.all(color: const Color(0x99FBBF24)),
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 52),
    );
  }
}

class _CosmicBackground extends StatelessWidget {
  const _CosmicBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x55C4B5FD);
    for (var index = 0; index < 45; index++) {
      final x = ((index * 83) % 997) / 997 * size.width;
      final y = ((index * 137) % 991) / 991 * size.height;
      canvas.drawCircle(Offset(x, y), index % 7 == 0 ? 1.6 : 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
