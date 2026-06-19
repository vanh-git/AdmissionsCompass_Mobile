import 'package:flutter/material.dart';

class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _result = '';

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _calculateNumerology() {
    final name = _nameController.text.trim();
    final dob = _dobController.text.trim();
    if (name.isEmpty || dob.isEmpty) {
      setState(() {
        _result = 'Vui lòng nhập họ tên và ngày sinh để xem kết quả.';
      });
      return;
    }

    final sum = name.toUpperCase().runes.fold<int>(0, (value, code) {
      if (code >= 65 && code <= 90) {
        return value + ((code - 65) % 9) + 1;
      }
      return value;
    });
    final lifePath = sum % 9 == 0 ? 9 : sum % 9;

    setState(() {
      _result =
          'Số đường đời của bạn là $lifePath.\n'
          'Số này gợi ý: ${_numerologyMeaning(lifePath)}';
    });
  }

  String _numerologyMeaning(int number) {
    switch (number) {
      case 1:
        return 'Lãnh đạo, độc lập, quyết đoán.';
      case 2:
        return 'Hòa nhã, hợp tác, nhạy cảm.';
      case 3:
        return 'Sáng tạo, giao tiếp, nhiệt huyết.';
      case 4:
        return 'Ổn định, kỷ luật, thực tế.';
      case 5:
        return 'Tự do, phiêu lưu, linh hoạt.';
      case 6:
        return 'Trách nhiệm, chăm sóc, gia đình.';
      case 7:
        return 'Sâu sắc, trực giác, phân tích.';
      case 8:
        return 'Tham vọng, quản lý, hiệu quả.';
      case 9:
        return 'Nhân ái, lý tưởng, vị tha.';
      default:
        return 'Khám phá thêm về con số của bạn.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thần số học')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Thần số học',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nhập tên và ngày sinh để khám phá con số định mệnh của bạn.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Ngày sinh (dd/mm/yyyy)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF059669),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _calculateNumerology,
              child: const Text('Tính toán ngay'),
            ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
