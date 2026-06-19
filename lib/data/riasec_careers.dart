import 'riasec_questions.dart';

class CareerSuggestion {
  final String description;
  final List<String> majors;

  CareerSuggestion({required this.description, required this.majors});
}

final Map<RIASECType, List<String>> singleTypeCareers = {
  RIASECType.R: [
    'Kỹ sư cơ khí',
    'Công nghệ ô tô',
    'Kỹ thuật xây dựng',
    'Điện tử - tự động hóa',
  ],
  RIASECType.I: [
    'Khoa học dữ liệu',
    'Công nghệ thông tin',
    'Vật lý kỹ thuật',
    'Khoa học máy tính',
  ],
  RIASECType.A: [
    'Thiết kế đồ họa',
    'Truyền thông đa phương tiện',
    'Sáng tác âm nhạc',
    'Nghệ thuật thị giác',
  ],
  RIASECType.S: [
    'Giáo dục mầm non',
    'Tâm lý học',
    'Y tế công cộng',
    'Xã hội học',
  ],
  RIASECType.E: [
    'Quản trị kinh doanh',
    'Marketing',
    'Luật thương mại',
    'Quản lý dự án',
  ],
  RIASECType.C: [
    'Kế toán',
    'Kiểm toán',
    'Quản trị văn phòng',
    'Quản trị nhân sự',
  ],
};

CareerSuggestion calculateCareerSuggestion(List<RIASECType> topTypes) {
  if (topTypes.isEmpty) {
    return CareerSuggestion(
      description:
          'Kết quả chưa được xác định. Vui lòng làm lại bài kiểm tra để nhận định hướng nghề nghiệp phù hợp.',
      majors: [],
    );
  }

  final majors = <String>[];
  for (final type in topTypes) {
    majors.addAll(singleTypeCareers[type] ?? []);
  }

  return CareerSuggestion(
    description:
        'Những ngành học gợi ý dựa trên loại tính cách RIASEC hàng đầu của bạn.',
    majors: majors.take(8).toList(),
  );
}
