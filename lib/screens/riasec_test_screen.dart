import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/riasec_careers.dart';
import '../data/riasec_questions.dart';

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

class RIASECTestScreen extends StatefulWidget {
  const RIASECTestScreen({super.key});

  @override
  State<RIASECTestScreen> createState() => _RIASECTestScreenState();
}

class _RIASECTestScreenState extends State<RIASECTestScreen> {
  static const _questionsPerPage = 6;
  static const _primary = Color(0xFF2563EB);
  static const _background = Color(0xFFF5F7FB);

  final _answers = <int, int>{};
  final _scrollController = ScrollController();
  TestPhase _phase = TestPhase.intro;
  int _currentPage = 0;
  int? _highlightedQuestion;
  String? _errorMessage;

  int get _totalPages => (riasecQuestions.length / _questionsPerPage).ceil();
  int get _pageStart => _currentPage * _questionsPerPage;
  List<RIASECQuestion> get _currentQuestions =>
      riasecQuestions.skip(_pageStart).take(_questionsPerPage).toList();
  Map<RIASECType, int> get _scores => calculateScores(_answers);
  List<RIASECType> get _topTypes => getTopTypes(_scores);
  bool get _isComplete => _answers.length == riasecQuestions.length;
  bool get _canProceed =>
      _currentQuestions.every((question) => _answers.containsKey(question.id));

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _answer(int questionId, int value) {
    setState(() {
      _answers[questionId] = value;
      if (_highlightedQuestion == questionId) {
        _highlightedQuestion = null;
        _errorMessage = null;
      }
    });
  }

  void _showMissingAnswer(RIASECQuestion question, String message) {
    setState(() {
      _highlightedQuestion = question.id;
      _errorMessage = message;
    });
    _scrollToTop();
  }

  void _nextPage() {
    if (!_canProceed) {
      _showMissingAnswer(
        _currentQuestions.firstWhere(
          (question) => !_answers.containsKey(question.id),
        ),
        'Bạn chưa trả lời hết các câu hỏi trên trang này.',
      );
      return;
    }
    setState(() {
      _currentPage++;
      _errorMessage = null;
      _highlightedQuestion = null;
    });
    _scrollToTop();
  }

  void _previousPage() {
    if (_currentPage == 0) return;
    setState(() {
      _currentPage--;
      _errorMessage = null;
      _highlightedQuestion = null;
    });
    _scrollToTop();
  }

  Future<void> _submit() async {
    if (!_isComplete) {
      final question = riasecQuestions.firstWhere(
        (item) => !_answers.containsKey(item.id),
      );
      setState(
        () => _currentPage =
            riasecQuestions.indexOf(question) ~/ _questionsPerPage,
      );
      _showMissingAnswer(
        question,
        'Bạn còn câu hỏi chưa trả lời. Hãy hoàn thành trước khi xem kết quả.',
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'riasecResults',
      jsonEncode(_scores.map((type, score) => MapEntry(type.name, score))),
    );
    if (!mounted) return;
    setState(() => _phase = TestPhase.result);
    _scrollToTop();
  }

  void _restart() {
    setState(() {
      _phase = TestPhase.intro;
      _currentPage = 0;
      _answers.clear();
      _errorMessage = null;
      _highlightedQuestion = null;
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      TestPhase.intro => _buildIntro(),
      TestPhase.quiz => _buildQuiz(),
      TestPhase.result => _buildResult(),
    };
  }

  Widget _page({required String title, required Widget child}) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
      ),
      body: child,
    );
  }

  Widget _buildIntro() {
    return _page(
      title: 'Trắc nghiệm RIASEC',
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 38,
              backgroundColor: _primary,
              child: Icon(Icons.explore, size: 38, color: Colors.white),
            ),
            const SizedBox(height: 18),
            const Text(
              'Khám phá nghề nghiệp phù hợp với tính cách của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mô hình RIASEC là gì?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Mô hình RIASEC (Holland Code) do nhà tâm lý học John Holland phát triển, giúp xác định sở thích nghề nghiệp dựa trên 6 nhóm tính cách cơ bản.',
                    style: TextStyle(height: 1.5, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth > 560
                          ? (constraints.maxWidth - 24) / 3
                          : (constraints.maxWidth - 12) / 2;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: riasecLabels.entries
                            .map(
                              (entry) => SizedBox(
                                width: width,
                                child: _typeTile(entry.key, entry.value),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hướng dẫn làm bài',
                          style: TextStyle(
                            color: Color(0xFF1E40AF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '✓ 60 câu hỏi, chia thành 10 trang\n'
                          '✓ Chọn mức phù hợp từ 1–4 điểm\n'
                          '✓ Trả lời thật lòng, không có đáp án đúng sai\n'
                          '✓ Thời gian khoảng 10–15 phút',
                          style: TextStyle(
                            color: Color(0xFF1D4ED8),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => setState(() => _phase = TestPhase.quiz),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Bắt đầu làm bài'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTile(RIASECType type, RIASECLabel label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            '${type.name} – ${label.name}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label.fullName,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final progress = _answers.length / riasecQuestions.length;
    return _page(
      title: 'RIASEC • Trang ${_currentPage + 1}/$_totalPages',
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_answers.length}/${riasecQuestions.length} câu đã trả lời',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('${(progress * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    color: _primary,
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(
                  '⚠️ $_errorMessage',
                  style: const TextStyle(color: Color(0xFFB91C1C)),
                ),
              ),
            ],
            const SizedBox(height: 14),
            ..._currentQuestions.asMap().entries.map(
              (entry) => _questionCard(entry.value, _pageStart + entry.key + 1),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentPage == 0 ? null : _previousPage,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Trang trước'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _currentPage == _totalPages - 1
                        ? _submit
                        : _nextPage,
                    icon: Icon(
                      _currentPage == _totalPages - 1
                          ? Icons.check_circle
                          : Icons.chevron_right,
                    ),
                    label: Text(
                      _currentPage == _totalPages - 1
                          ? 'Xem kết quả'
                          : 'Trang sau',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(RIASECQuestion question, int number) {
    final selected = _answers[question.id];
    final highlighted = _highlightedQuestion == question.id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected != null
            ? const Color(0xFFF0FDF4)
            : highlighted
            ? const Color(0xFFFEF2F2)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          width: 2,
          color: highlighted
              ? const Color(0xFFEF4444)
              : selected != null
              ? const Color(0xFF4ADE80)
              : Colors.transparent,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: selected == null
                    ? const Color(0xFF9CA3AF)
                    : _primary,
                foregroundColor: Colors.white,
                child: Text('$number'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: answerOptions.map((option) {
              final isSelected = selected == option.value;
              return ChoiceChip(
                selected: isSelected,
                label: Text(option.label),
                onSelected: (_) => _answer(question.id, option.value),
                selectedColor: _primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4B5563),
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final suggestions = getCareerSuggestions(_topTypes);
    final sortedScores = _scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _page(
      title: 'Kết quả RIASEC',
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFF97316),
              child: Icon(Icons.emoji_events, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text(
              'Kết quả của bạn',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Mã Holland: ${suggestions.code}',
              style: const TextStyle(
                color: _primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _card(
              child: Column(
                children: [
                  const Text(
                    'BIỂU ĐỒ ĐIỂM SỐ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 18),
                  ...sortedScores.map(
                    (entry) => _scoreRow(entry.key, entry.value),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 260,
                    child: CustomPaint(
                      painter: _RadarChartPainter(_scores),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏆 Top 3 nhóm tính cách',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ..._topTypes.asMap().entries.map(
                    (entry) => _topTypeCard(entry.key, entry.value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 Ngành học phù hợp với bạn',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _careerSection(
                    'Nhóm chính ${_topTypes[0].name} – ${riasecLabels[_topTypes[0]]!.name}',
                    suggestions.primary,
                    const Color(0xFFDBEAFE),
                    const Color(0xFF1D4ED8),
                  ),
                  if (suggestions.combo != null) ...[
                    const Divider(height: 32),
                    _careerSection(
                      'Kết hợp ${_topTypes[0].name}${_topTypes[1].name}',
                      suggestions.combo!,
                      const Color(0xFFF3E8FF),
                      const Color(0xFF7E22CE),
                    ),
                  ],
                  const Divider(height: 32),
                  _careerSection(
                    'Ngành từ nhóm ${_topTypes[1].name}',
                    singleTypeCareers[_topTypes[1]]!,
                    const Color(0xFFDCFCE7),
                    const Color(0xFF15803D),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: const Text('Làm lại bài test'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(RIASECType type, int score) {
    final label = riasecLabels[type]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '${label.icon} ${type.name} – ${label.name}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: score / 40,
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
              color: _primary,
              backgroundColor: const Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$score/40',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _topTypeCard(int index, RIASECType type) {
    final colors = [
      const Color(0xFFFEF3C7),
      const Color(0xFFF3F4F6),
      const Color(0xFFFFEDD5),
    ];
    final medals = ['🥇', '🥈', '🥉'];
    final label = riasecLabels[type]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors[index],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(medals[index], style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${label.icon} ${type.name} – ${label.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  label.description,
                  style: const TextStyle(color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
          Text(
            '${_scores[type]}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _careerSection(
    String title,
    CareerMapping mapping,
    Color chipColor,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          mapping.description,
          style: const TextStyle(color: Color(0xFF4B5563), height: 1.4),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: mapping.majors
              .map(
                (major) => Chip(
                  label: Text(major),
                  backgroundColor: chipColor,
                  labelStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final Map<RIASECType, int> scores;

  _RadarChartPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;
    const types = RIASECType.values;
    final gridPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke;

    List<Offset> pointsFor(double scale) => List.generate(types.length, (i) {
      final angle = -math.pi / 2 + i * math.pi * 2 / types.length;
      return center + Offset(math.cos(angle), math.sin(angle)) * radius * scale;
    });

    Path polygon(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      return path..close();
    }

    for (final scale in [0.33, 0.66, 1.0]) {
      canvas.drawPath(polygon(pointsFor(scale)), gridPaint);
    }

    final scorePoints = List.generate(types.length, (i) {
      final angle = -math.pi / 2 + i * math.pi * 2 / types.length;
      final scale = (scores[types[i]] ?? 0) / 40;
      return center + Offset(math.cos(angle), math.sin(angle)) * radius * scale;
    });
    canvas.drawPath(
      polygon(scorePoints),
      Paint()
        ..color = const Color(0x553B82F6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      polygon(scorePoints),
      Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < types.length; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / types.length;
      final labelOffset =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 20);
      final painter = TextPainter(
        text: TextSpan(
          text: types[i].name,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        labelOffset - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) =>
      oldDelegate.scores != scores;
}
