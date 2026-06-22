import 'riasec_questions.dart';

class CareerMapping {
  final List<String> majors;
  final String description;

  const CareerMapping({required this.majors, required this.description});
}

class CareerSuggestions {
  final CareerMapping primary;
  final CareerMapping? combo;
  final String code;

  const CareerSuggestions({
    required this.primary,
    required this.combo,
    required this.code,
  });
}

const singleTypeCareers = <RIASECType, CareerMapping>{
  RIASECType.R: CareerMapping(
    majors: [
      'Kỹ thuật cơ khí',
      'Xây dựng',
      'Điện – Điện tử',
      'Công nghệ ô tô',
      'Hàng hải',
      'Công nghệ sản xuất',
      'Kỹ thuật môi trường',
      'Nông nghiệp',
    ],
    description:
        'Bạn phù hợp với các ngành kỹ thuật, cần sự khéo léo và làm việc thực tế.',
  ),
  RIASECType.I: CareerMapping(
    majors: [
      'Công nghệ thông tin',
      'Y khoa',
      'Dược học',
      'Sinh học',
      'Khoa học dữ liệu',
      'Kỹ thuật phần mềm',
      'Hóa học',
      'Vật lý',
    ],
    description:
        'Bạn phù hợp với các ngành nghiên cứu, cần tư duy logic và phân tích.',
  ),
  RIASECType.A: CareerMapping(
    majors: [
      'Thiết kế đồ họa',
      'Truyền thông đa phương tiện',
      'Báo chí',
      'Kiến trúc',
      'Marketing sáng tạo',
      'Nghệ thuật',
      'Điện ảnh',
      'Thiết kế thời trang',
    ],
    description: 'Bạn phù hợp với các ngành sáng tạo, cần sự tự do và thẩm mỹ.',
  ),
  RIASECType.S: CareerMapping(
    majors: [
      'Sư phạm',
      'Tâm lý học',
      'Điều dưỡng',
      'Công tác xã hội',
      'Quản trị nhân sự',
      'Giáo dục mầm non',
      'Y tế công cộng',
      'Xã hội học',
    ],
    description:
        'Bạn phù hợp với các ngành xã hội, cần kỹ năng giao tiếp và sự đồng cảm.',
  ),
  RIASECType.E: CareerMapping(
    majors: [
      'Quản trị kinh doanh',
      'Marketing',
      'Thương mại điện tử',
      'Kinh tế quốc tế',
      'Luật kinh doanh',
      'Khởi nghiệp',
      'Quan hệ công chúng',
      'Quản lý dự án',
    ],
    description:
        'Bạn phù hợp với các ngành kinh doanh, cần kỹ năng lãnh đạo và thuyết phục.',
  ),
  RIASECType.C: CareerMapping(
    majors: [
      'Kế toán',
      'Kiểm toán',
      'Tài chính – Ngân hàng',
      'Logistics',
      'Hành chính văn phòng',
      'Quản lý dữ liệu',
      'Thống kê',
      'Quản trị văn phòng',
    ],
    description:
        'Bạn phù hợp với các ngành nghiệp vụ, cần sự tỉ mỉ và có tổ chức.',
  ),
};

CareerMapping _combo(
  List<String> majors,
  String first,
  String second,
  String field,
) {
  return CareerMapping(
    majors: majors,
    description:
        'Kết hợp giữa $first và $second – phù hợp với nhóm ngành $field.',
  );
}

final comboTypeCareers = <String, CareerMapping>{
  for (final code in ['RI', 'IR'])
    code: _combo(
      [
        'Công nghệ thông tin',
        'Kỹ thuật phần mềm',
        'Kỹ thuật điện tử',
        'Cơ điện tử',
        'Tự động hóa',
      ],
      code == 'RI' ? 'thực hành' : 'nghiên cứu',
      code == 'RI' ? 'nghiên cứu' : 'thực hành',
      'công nghệ',
    ),
  for (final code in ['RA', 'AR'])
    code: _combo(
      [
        'Kiến trúc',
        'Thiết kế nội thất',
        'Thiết kế công nghiệp',
        'Mỹ thuật ứng dụng',
      ],
      code == 'RA' ? 'kỹ thuật' : 'sáng tạo',
      code == 'RA' ? 'sáng tạo' : 'kỹ thuật',
      'thiết kế',
    ),
  for (final code in ['IS', 'SI'])
    code: _combo(
      ['Y khoa', 'Tâm lý học', 'Điều dưỡng', 'Dinh dưỡng', 'Vật lý trị liệu'],
      code == 'IS' ? 'nghiên cứu' : 'xã hội',
      code == 'IS' ? 'xã hội' : 'nghiên cứu',
      'y tế và sức khỏe',
    ),
  for (final code in ['EA', 'AE'])
    code: _combo(
      [
        'Marketing',
        'Truyền thông',
        'Quan hệ công chúng',
        'Quảng cáo',
        'Sự kiện',
      ],
      code == 'EA' ? 'kinh doanh' : 'sáng tạo',
      code == 'EA' ? 'sáng tạo' : 'kinh doanh',
      'truyền thông',
    ),
  for (final code in ['CE', 'EC'])
    code: _combo(
      [
        'Tài chính – Ngân hàng',
        'Kinh doanh quốc tế',
        'Quản trị tài chính',
        'Đầu tư',
      ],
      code == 'CE' ? 'tổ chức' : 'kinh doanh',
      code == 'CE' ? 'kinh doanh' : 'tổ chức',
      'tài chính',
    ),
  for (final code in ['AS', 'SA'])
    code: _combo(
      [
        'Sư phạm nghệ thuật',
        'Giáo dục âm nhạc',
        'Giáo dục mỹ thuật',
        'Thiết kế giáo dục',
      ],
      code == 'AS' ? 'sáng tạo' : 'xã hội',
      code == 'AS' ? 'xã hội' : 'sáng tạo',
      'giáo dục nghệ thuật',
    ),
  for (final code in ['SE', 'ES'])
    code: _combo(
      [
        'Quản trị nhân sự',
        'Đào tạo doanh nghiệp',
        'Tư vấn kinh doanh',
        'Sales',
      ],
      code == 'SE' ? 'xã hội' : 'kinh doanh',
      code == 'SE' ? 'kinh doanh' : 'xã hội',
      'nhân sự và tư vấn',
    ),
  for (final code in ['RC', 'CR'])
    code: _combo(
      [
        'Quản lý sản xuất',
        'Quản lý chất lượng',
        'Kỹ thuật công nghiệp',
        'An toàn lao động',
      ],
      code == 'RC' ? 'thực hành' : 'tổ chức',
      code == 'RC' ? 'tổ chức' : 'thực hành',
      'quản lý sản xuất',
    ),
  for (final code in ['IC', 'CI'])
    code: _combo(
      [
        'Khoa học dữ liệu',
        'Phân tích kinh doanh',
        'Thống kê',
        'Nghiên cứu thị trường',
      ],
      code == 'IC' ? 'nghiên cứu' : 'tổ chức',
      code == 'IC' ? 'tổ chức' : 'nghiên cứu',
      'phân tích dữ liệu',
    ),
  for (final code in ['IA', 'AI'])
    code: _combo(
      [
        'Khoa học máy tính',
        'Phát triển game',
        'UX Research',
        'Thiết kế sản phẩm số',
      ],
      code == 'IA' ? 'nghiên cứu' : 'sáng tạo',
      code == 'IA' ? 'sáng tạo' : 'nghiên cứu',
      'công nghệ sáng tạo',
    ),
  for (final code in ['RE', 'ER'])
    code: _combo(
      ['Quản lý xây dựng', 'Kinh doanh bất động sản', 'Quản lý dự án xây dựng'],
      code == 'RE' ? 'thực hành' : 'kinh doanh',
      code == 'RE' ? 'kinh doanh' : 'thực hành',
      'xây dựng và bất động sản',
    ),
  for (final code in ['RS', 'SR'])
    code: _combo(
      [
        'Giáo dục thể chất',
        'Huấn luyện viên',
        'Vật lý trị liệu',
        'Kỹ thuật y sinh',
      ],
      code == 'RS' ? 'thực hành' : 'xã hội',
      code == 'RS' ? 'xã hội' : 'thực hành',
      'thể thao và y tế',
    ),
  for (final code in ['IE', 'EI'])
    code: _combo(
      [
        'Quản lý công nghệ',
        'Startup công nghệ',
        'Product Manager',
        'Tư vấn CNTT',
      ],
      code == 'IE' ? 'nghiên cứu' : 'kinh doanh',
      code == 'IE' ? 'kinh doanh' : 'nghiên cứu',
      'quản lý công nghệ',
    ),
  for (final code in ['AC', 'CA'])
    code: _combo(
      ['Thiết kế đồ họa', 'Biên tập viên', 'Content Creator', 'Social Media'],
      code == 'AC' ? 'sáng tạo' : 'tổ chức',
      code == 'AC' ? 'tổ chức' : 'sáng tạo',
      'nội dung số',
    ),
  for (final code in ['SC', 'CS'])
    code: _combo(
      [
        'Quản lý giáo dục',
        'Hành chính y tế',
        'Thư ký y khoa',
        'Quản lý bệnh viện',
      ],
      code == 'SC' ? 'xã hội' : 'tổ chức',
      code == 'SC' ? 'tổ chức' : 'xã hội',
      'quản lý xã hội',
    ),
};

Map<RIASECType, int> calculateScores(Map<int, int> answers) {
  final scores = {for (final type in RIASECType.values) type: 0};
  for (final question in riasecQuestions) {
    scores[question.type] =
        scores[question.type]! + (answers[question.id] ?? 0);
  }
  return scores;
}

List<RIASECType> getTopTypes(Map<RIASECType, int> scores, {int count = 3}) {
  final sorted = scores.entries.toList()
    ..sort((a, b) {
      final scoreComparison = b.value.compareTo(a.value);
      return scoreComparison != 0
          ? scoreComparison
          : a.key.index.compareTo(b.key.index);
    });
  return sorted.take(count).map((entry) => entry.key).toList();
}

CareerSuggestions getCareerSuggestions(List<RIASECType> topTypes) {
  if (topTypes.length < 2) {
    throw ArgumentError('At least two RIASEC types are required.');
  }
  final code = topTypes.map((type) => type.name).join();
  final comboCode = '${topTypes[0].name}${topTypes[1].name}';
  return CareerSuggestions(
    primary: singleTypeCareers[topTypes.first]!,
    combo: comboTypeCareers[comboCode],
    code: code,
  );
}
