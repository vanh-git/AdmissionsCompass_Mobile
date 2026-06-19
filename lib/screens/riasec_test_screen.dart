import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/riasec_careers.dart';
import '../data/riasec_questions.dart';

class RIASECTestScreen extends StatefulWidget {
  const RIASECTestScreen({super.key});

  @override
  State<RIASECTestScreen> createState() => _RIASECTestScreenState();
}

enum TestPhase { intro, quiz, result }

class AnswerOption {
  final int value;
  final String label;

  const AnswerOption(this.value, this.label);
}

const answerOptions = [
  AnswerOption(4, 'Rất đúng'),
  AnswerOption(3, 'Khá đúng'),
  AnswerOption(2, 'Bình thường'),
  AnswerOption(1, 'Không đúng'),
];

class _RIASECTestScreenState extends State<RIASECTestScreen> {
  TestPhase _phase = TestPhase.intro;
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  Map<RIASECType, int> get _scores => calculateScores(_answers);
  List<RIASECType> get _topTypes => getTopTypes(_scores);
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveResults() async {
    final prefs = await SharedPreferences.getInstance();
    final result = _scores.map((key, value) => MapEntry(key.name, value));
    await prefs.setString('riasecResults', jsonEncode(result));
  }

  void _selectAnswer(int value) {
    setState(() {
      _answers[riasecQuestions[_currentIndex].id] = value;
    });

    if (_currentIndex < riasecQuestions.length - 1) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _currentIndex += 1);
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _finishQuiz() async {
    await _saveResults();
    setState(() {
      _phase = TestPhase.result;
    });
  }

  void _restartQuiz() {
    setState(() {
      _phase = TestPhase.intro;
      _currentIndex = 0;
      _answers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case TestPhase.intro:
        return _buildIntro(context);
      case TestPhase.quiz:
        return _buildQuiz(context);
      case TestPhase.result:
        return _buildResult(context);
    }
  }

  Widget _buildIntro(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trắc nghiệm RIASEC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Trắc nghiệm RIASEC',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Khám phá định hướng nghề nghiệp phù hợp với bạn',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              'ℹ️ Về bài trắc nghiệm',
              '• 60 câu hỏi về sở thích và khả năng\n• Thời gian hoàn thành: 15-20 phút\n• Kết quả: Gợi ý ngành học phù hợp\n• Bạn có thể tạm dừng và tiếp tục sau',
            ),
            const SizedBox(height: 20),
            const Text(
              '6 Hạng mục RIASEC:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: riasecLabels.entries.map((entry) {
                return Container(
                  width: (MediaQuery.of(context).size.width - 56) / 2,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.value.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.key.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => setState(() => _phase = TestPhase.quiz),
                child: const Text('Bắt đầu trắc nghiệm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz(BuildContext context) {
    final currentQuestion = riasecQuestions[_currentIndex];
    final progress = ((_answers.length / riasecQuestions.length) * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('RIASEC Test')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: _answers.length / riasecQuestions.length,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: const Color(0xFF059669),
                ),
                const SizedBox(height: 8),
                Text(
                  'Câu ${_currentIndex + 1}/${riasecQuestions.length} • $progress%',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Câu ${_currentIndex + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentQuestion.type.name,
                                style: const TextStyle(
                                  color: Color(0xFF0369A1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          currentQuestion.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: answerOptions.map((option) {
                      final isSelected =
                          _answers[currentQuestion.id] == option.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF8FAFC),
                            foregroundColor: isSelected
                                ? const Color(0xFF059669)
                                : const Color(0xFF334155),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                          onPressed: () => _selectAnswer(option.value),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF059669)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFD1D5DB),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentIndex > 0
                              ? () => setState(
                                  () => _currentIndex = _currentIndex - 1,
                                )
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('← Trước'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _answers.length == riasecQuestions.length &&
                                  _currentIndex == riasecQuestions.length - 1
                              ? _finishQuiz
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Xem kết quả'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final careerSuggestion = calculateCareerSuggestion(_topTypes);
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả RIASEC')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Kết quả của bạn',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Column(
              children: _topTypes.asMap().entries.map((entry) {
                final index = entry.key;
                final type = entry.value;
                final score = _scores[type]!;
                final label = riasecLabels[type]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          index == 0 ? 'Chính' : 'Phụ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(label.icon, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label.fullName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Điểm: $score/40',
                              style: const TextStyle(
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngành học gợi ý',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    careerSuggestion.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...careerSuggestion.majors.map(
                    (major) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF059669),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              major,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              padding: const EdgeInsets.all(16),
              child: const Text(
                '💡 Kết quả chỉ mang tính tham khảo. Hãy kết hợp với sở thích, năng lực và cơ hội thực tế khi đưa ra lựa chọn.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF92400E),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF059669)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Chia sẻ',
                      style: TextStyle(color: Color(0xFF059669)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF059669),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Làm lại'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Map<RIASECType, int> calculateScores(Map<int, int> answers) {
  final scores = {for (var type in RIASECType.values) type: 0};
  for (final q in riasecQuestions) {
    final answer = answers[q.id];
    if (answer != null) {
      scores[q.type] = scores[q.type]! + answer;
    }
  }
  return scores;
}

List<RIASECType> getTopTypes(Map<RIASECType, int> scores) {
  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(3).map((entry) => entry.key).toList();
}
