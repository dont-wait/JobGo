import 'package:flutter_test/flutter_test.dart';
import 'package:jobgo/data/services/gemini_cv_analysis_service.dart';

void main() {
  test('detects PDF urls', () {
    expect(GeminiCvAnalysisService.isPdfUrl('https://a.com/file.pdf'), true);
    expect(
      GeminiCvAnalysisService.isPdfUrl('https://a.com/file.pdf?token=123'),
      true,
    );
    expect(GeminiCvAnalysisService.isPdfUrl('https://a.com/file.docx'), false);
  });
}
