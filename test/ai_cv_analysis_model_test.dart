import 'package:flutter_test/flutter_test.dart';
import 'package:jobgo/data/models/ai_cv_analysis_model.dart';

void main() {
  test('parses Gemini JSON and clamps score', () {
    final model = AiCvAnalysisModel.fromGeminiJson(
      json: {
        'matchScore': 145,
        'summary': 'Strong fit',
        'strengths': ['Flutter', 'Dart'],
        'gaps': ['Docker'],
        'suggestions': ['Add deployment experience'],
        'coverLetterTips': ['Mention job title'],
        'riskFlags': ['Missing backend experience'],
      },
      applicationId: 10,
      jobId: 20,
      candidateId: 30,
      cvUrl: 'https://example.com/cv.pdf',
      languageCode: 'vi',
      model: 'gemini-2.5-flash',
    );

    expect(model.matchScore, 100);
    expect(model.strengths, ['Flutter', 'Dart']);
    expect(model.gaps, ['Docker']);
    expect(model.summary, 'Strong fit');
  });

  test('parses database JSON safely', () {
    final model = AiCvAnalysisModel.fromJson({
      'id': 1,
      'application_id': 2,
      'job_id': 3,
      'candidate_id': 4,
      'cv_url': 'https://example.com/cv.pdf',
      'match_score': 88,
      'summary': 'Great match',
      'strengths': ['Leadership'],
      'gaps': ['AWS'],
      'suggestions': ['Add AWS projects'],
      'cover_letter_tips': ['Keep it concise'],
      'risk_flags': ['Needs validation'],
      'language_code': 'vi',
      'model': 'gemini-2.5-flash',
    });

    expect(model.id, 1);
    expect(model.matchScore, 88);
    expect(model.coverLetterTips, ['Keep it concise']);
  });
}
