class NumerologyProfile {
  final int number;
  final String name;
  final String keyword;
  final String essence;
  final String lightSide;
  final String darkSide;
  final List<String> strengths;
  final List<String> weaknesses;
  final String workEnv;
  final List<String> careers;
  final List<String> majors;
  final String lesson;
  final String advice;
  final String emoji;

  const NumerologyProfile({
    required this.number,
    required this.name,
    required this.keyword,
    required this.essence,
    required this.lightSide,
    required this.darkSide,
    required this.strengths,
    required this.weaknesses,
    required this.workEnv,
    required this.careers,
    required this.majors,
    required this.lesson,
    required this.advice,
    required this.emoji,
  });
}

class NumerologyResult {
  final DateTime birthDate;
  final String fullName;
  final int lifePath;
  final int birthday;
  final int attitude;
  final int destiny;
  final int soulUrge;
  final int personality;

  const NumerologyResult({
    required this.birthDate,
    required this.fullName,
    required this.lifePath,
    required this.birthday,
    required this.attitude,
    required this.destiny,
    required this.soulUrge,
    required this.personality,
  });
}
