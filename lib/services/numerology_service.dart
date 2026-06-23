import '../models/numerology_profile.dart';

class NumerologyService {
  NumerologyService._();

  static const _letterValues = {
    'a': 1,
    'j': 1,
    's': 1,
    'b': 2,
    'k': 2,
    't': 2,
    'c': 3,
    'l': 3,
    'u': 3,
    'd': 4,
    'm': 4,
    'v': 4,
    'e': 5,
    'n': 5,
    'w': 5,
    'f': 6,
    'o': 6,
    'x': 6,
    'g': 7,
    'p': 7,
    'y': 7,
    'h': 8,
    'q': 8,
    'z': 8,
    'i': 9,
    'r': 9,
  };
  static const _vowels = {'a', 'e', 'i', 'o', 'u', 'y'};

  static int reduce(int number) {
    if ({11, 22, 33}.contains(number) || number < 10) return number;
    final sum = number
        .toString()
        .split('')
        .fold<int>(0, (value, digit) => value + int.parse(digit));
    return reduce(sum);
  }

  static int lifePath(DateTime date) =>
      reduce(reduce(date.day) + reduce(date.month) + reduce(date.year));

  static int birthday(DateTime date) => reduce(date.day);

  static int attitude(DateTime date) =>
      reduce(reduce(date.day) + reduce(date.month));

  static String normalizeVietnamese(String input) {
    const source =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const target =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var value = input.toLowerCase();
    for (var index = 0; index < source.length; index++) {
      value = value.replaceAll(source[index], target[index]);
    }
    return value.replaceAll(RegExp('[^a-z]'), '');
  }

  static int _letterNumber(String name, bool Function(String) include) {
    final letters = normalizeVietnamese(name).split('').where(include);
    return reduce(
      letters.fold<int>(0, (sum, letter) => sum + (_letterValues[letter] ?? 0)),
    );
  }

  static int destiny(String name) => _letterNumber(name, (_) => true);
  static int soulUrge(String name) =>
      _letterNumber(name, (letter) => _vowels.contains(letter));
  static int personality(String name) =>
      _letterNumber(name, (letter) => !_vowels.contains(letter));

  static NumerologyResult calculate(String fullName, DateTime birthDate) {
    return NumerologyResult(
      birthDate: birthDate,
      fullName: fullName,
      lifePath: lifePath(birthDate),
      birthday: birthday(birthDate),
      attitude: attitude(birthDate),
      destiny: destiny(fullName),
      soulUrge: soulUrge(fullName),
      personality: personality(fullName),
    );
  }
}
