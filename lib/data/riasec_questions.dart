enum RIASECType { R, I, A, S, E, C }

class RIASECLabel {
  final String name;
  final String fullName;
  final String description;
  final String icon;

  const RIASECLabel({
    required this.name,
    required this.fullName,
    required this.description,
    required this.icon,
  });
}

class RIASECQuestion {
  final int id;
  final String text;
  final RIASECType type;

  const RIASECQuestion({
    required this.id,
    required this.text,
    required this.type,
  });
}

const Map<RIASECType, RIASECLabel> riasecLabels = {
  RIASECType.R: RIASECLabel(
    name: 'Realistic',
    fullName: 'Kỹ thuật – Thực hành – Vận động',
    description: 'Thích làm việc với máy móc, công cụ, hoạt động thực tế.',
    icon: '🔧',
  ),
  RIASECType.I: RIASECLabel(
    name: 'Investigative',
    fullName: 'Phân tích – Nghiên cứu – Tư duy logic',
    description: 'Thích khám phá, phân tích và hiểu sâu vấn đề.',
    icon: '🔬',
  ),
  RIASECType.A: RIASECLabel(
    name: 'Artistic',
    fullName: 'Sáng tạo – Nghệ thuật – Tự do',
    description: 'Thích sáng tạo, thiết kế và trình bày ý tưởng.',
    icon: '🎨',
  ),
  RIASECType.S: RIASECLabel(
    name: 'Social',
    fullName: 'Giao tiếp – Giúp đỡ – Hỗ trợ',
    description: 'Thích làm việc với con người và giúp đỡ người khác.',
    icon: '🤝',
  ),
  RIASECType.E: RIASECLabel(
    name: 'Enterprising',
    fullName: 'Lãnh đạo – Kinh doanh – Thuyết phục',
    description: 'Thích dẫn dắt, tạo ảnh hưởng và xây dựng kết quả.',
    icon: '💼',
  ),
  RIASECType.C: RIASECLabel(
    name: 'Conventional',
    fullName: 'Tổ chức – Số liệu – Quy trình',
    description: 'Thích làm việc theo hệ thống, chi tiết và chính xác.',
    icon: '📊',
  ),
};

const List<RIASECQuestion> riasecQuestions = [
  // R examples
  RIASECQuestion(
    id: 1,
    text: 'Tôi thích sửa chữa thiết bị điện hoặc máy móc.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 2,
    text: 'Tôi thích làm việc ngoài trời hơn là ngồi văn phòng.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 3,
    text: 'Tôi hứng thú với lắp ráp, xây dựng hoặc chế tạo.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 4,
    text: 'Tôi thích học các môn như Vật lý và Công nghệ.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 5,
    text: 'Tôi thích làm việc với công cụ và dụng cụ thực tế.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 6,
    text: 'Tôi thấy mình khéo tay và thực tế.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 7,
    text: 'Tôi thích quan sát cách máy móc vận hành.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 8,
    text: 'Tôi thích công việc có tính hành động.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 9,
    text: 'Tôi thích giải quyết vấn đề bằng cách thử nghiệm.',
    type: RIASECType.R,
  ),
  RIASECQuestion(
    id: 10,
    text: 'Tôi muốn tạo ra sản phẩm hữu hình.',
    type: RIASECType.R,
  ),

  // I examples
  RIASECQuestion(
    id: 11,
    text: 'Tôi thích giải bài toán khó.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 12,
    text: 'Tôi thích tìm hiểu nguyên nhân của một hiện tượng.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 13,
    text: 'Tôi thích nghiên cứu chuyên sâu một vấn đề.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 14,
    text: 'Tôi hứng thú với khoa học và khám phá.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 15,
    text: 'Tôi thích đọc tài liệu học thuật.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 16,
    text: 'Tôi thích đặt câu hỏi “vì sao” về các vấn đề xung quanh.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 17,
    text: 'Tôi thích làm thí nghiệm để kiểm tra giả thuyết.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 18,
    text: 'Tôi thấy mình có tư duy logic tốt.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 19,
    text: 'Tôi thích phân tích dữ liệu và số liệu.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 20,
    text: 'Tôi muốn làm công việc thiên về nghiên cứu.',
    type: RIASECType.I,
  ),
  RIASECQuestion(
    id: 21,
    text: 'Tôi thích vẽ, thiết kế hoặc sáng tạo nội dung.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 22,
    text: 'Tôi không thích công việc quá khuôn mẫu.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 23,
    text: 'Tôi thích viết lách hoặc kể chuyện.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 24,
    text: 'Tôi yêu thích âm nhạc hoặc nghệ thuật.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 25,
    text: 'Tôi có nhiều ý tưởng độc đáo.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 26,
    text: 'Tôi thích thể hiện bản thân qua sản phẩm sáng tạo.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 27,
    text: 'Tôi thích công việc tự do hơn là gò bó.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 28,
    text: 'Tôi thích thiết kế hình ảnh hoặc video.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 29,
    text: 'Tôi thích sáng tạo hơn là làm theo quy trình.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 30,
    text: 'Tôi muốn công việc mang tính cá nhân cao.',
    type: RIASECType.A,
  ),
  RIASECQuestion(
    id: 31,
    text: 'Tôi thích giúp người khác giải quyết vấn đề.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 32,
    text: 'Tôi thích lắng nghe và tư vấn.',
    type: RIASECType.S,
  ),
  RIASECQuestion(id: 33, text: 'Tôi thích làm việc nhóm.', type: RIASECType.S),
  RIASECQuestion(
    id: 34,
    text: 'Tôi quan tâm đến cảm xúc người khác.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 35,
    text: 'Tôi thích dạy người khác điều mình biết.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 36,
    text: 'Tôi thích công việc liên quan đến con người.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 37,
    text: 'Tôi thấy vui khi giúp ai đó tiến bộ.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 38,
    text: 'Tôi thích môi trường giao tiếp nhiều.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 39,
    text: 'Tôi quan tâm đến giáo dục hoặc y tế.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 40,
    text: 'Tôi muốn tạo ảnh hưởng tích cực cho cộng đồng.',
    type: RIASECType.S,
  ),
  RIASECQuestion(
    id: 41,
    text: 'Tôi thích thuyết trình trước đám đông.',
    type: RIASECType.E,
  ),
  RIASECQuestion(id: 42, text: 'Tôi thích dẫn dắt nhóm.', type: RIASECType.E),
  RIASECQuestion(
    id: 43,
    text: 'Tôi muốn tự kinh doanh trong tương lai.',
    type: RIASECType.E,
  ),
  RIASECQuestion(
    id: 44,
    text: 'Tôi thích thương lượng và thuyết phục.',
    type: RIASECType.E,
  ),
  RIASECQuestion(
    id: 45,
    text: 'Tôi thích môi trường cạnh tranh.',
    type: RIASECType.E,
  ),
  RIASECQuestion(
    id: 46,
    text: 'Tôi quan tâm đến marketing và bán hàng.',
    type: RIASECType.E,
  ),
  RIASECQuestion(
    id: 47,
    text: 'Tôi thích đưa ra quyết định.',
    type: RIASECType.E,
  ),
  RIASECQuestion(
    id: 48,
    text: 'Tôi muốn tạo ra cơ hội kiếm tiền.',
    type: RIASECType.E,
  ),
  RIASECQuestion(
    id: 49,
    text: 'Tôi thích xây dựng chiến lược.',
    type: RIASECType.E,
  ),
  RIASECQuestion(id: 50, text: 'Tôi tự tin khi giao tiếp.', type: RIASECType.E),
  RIASECQuestion(
    id: 51,
    text: 'Tôi thích làm việc theo kế hoạch rõ ràng.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 52,
    text: 'Tôi thích sắp xếp dữ liệu, tài liệu.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 53,
    text: 'Tôi cẩn thận và chú ý chi tiết.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 54,
    text: 'Tôi thích làm việc với con số.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 55,
    text: 'Tôi thích công việc ổn định.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 56,
    text: 'Tôi thích tuân thủ quy trình.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 57,
    text: 'Tôi thấy mình có tính kỷ luật cao.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 58,
    text: 'Tôi thích phân tích báo cáo.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 59,
    text: 'Tôi thích làm việc trong môi trường có cấu trúc.',
    type: RIASECType.C,
  ),
  RIASECQuestion(
    id: 60,
    text: 'Tôi thích quản lý thông tin.',
    type: RIASECType.C,
  ),
];
