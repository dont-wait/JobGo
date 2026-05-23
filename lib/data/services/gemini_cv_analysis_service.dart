import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jobgo/core/utils/app_logger.dart';
import 'package:jobgo/data/models/ai_cv_analysis_model.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/data/models/job_model.dart';

class GeminiCvAnalysisService {
  static const String _defaultModel = 'gemini-2.5-flash';

  static bool isPdfUrl(String url) {
    final lower = url.toLowerCase().trim();
    if (lower.isEmpty) return false;
    final normalized = lower.split('?').first.split('#').first;
    return normalized.endsWith('.pdf');
  }

  Future<AiCvAnalysisModel> analyzeCv({
    required int? applicationId,
    required int jobId,
    required int candidateId,
    required String cvUrl,
    required JobModel job,
    required CandidateSupabaseModel candidate,
    required String coverLetter,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    final model =
        (dotenv.env['GEMINI_MODEL']?.trim().isNotEmpty ?? false)
        ? dotenv.env['GEMINI_MODEL']!.trim()
        : _defaultModel;

    if (apiKey.isEmpty) {
      throw StateError('Missing GEMINI_API_KEY in .env');
    }
    if (!isPdfUrl(cvUrl)) {
      throw UnsupportedError('AI analysis supports PDF only for now.');
    }

    final pdfBytes = await _downloadPdf(cvUrl);
    final prompt = _buildPrompt(job, candidate, coverLetter);

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );
    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'application/pdf',
                'data': base64Encode(pdfBytes),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
        'responseJsonSchema': _responseSchema(),
      },
    };

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 45));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      AppLogger.error(
        'Gemini request failed (${response.statusCode}): ${response.body}',
      );
      throw StateError('Gemini request failed: HTTP ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractTextResponse(jsonBody);
    final structured = jsonDecode(_normalizeJson(text)) as Map<String, dynamic>;

    return AiCvAnalysisModel.fromGeminiJson(
      json: structured,
      applicationId: applicationId,
      jobId: jobId,
      candidateId: candidateId,
      cvUrl: cvUrl,
      model: model,
    );
  }

  Future<List<int>> _downloadPdf(String cvUrl) async {
    final uri = Uri.tryParse(cvUrl);
    if (uri == null) {
      throw StateError('Invalid CV URL');
    }

    final response = await http.get(uri).timeout(const Duration(seconds: 30));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Failed to download CV');
    }
    if (response.bodyBytes.isEmpty) {
      throw StateError('Downloaded CV is empty');
    }
    return response.bodyBytes;
  }

  String _extractTextResponse(Map<String, dynamic> body) {
    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw StateError('Gemini returned no candidates');
    }
    final first = candidates.first;
    if (first is! Map<String, dynamic>) {
      throw StateError('Unexpected Gemini response format');
    }
    final content = first['content'];
    if (content is! Map<String, dynamic>) {
      throw StateError('Gemini content is missing');
    }
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      throw StateError('Gemini parts are missing');
    }
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] is String) {
        return part['text'] as String;
      }
    }
    throw StateError('Gemini text response is missing');
  }

  String _normalizeJson(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return text.trim();
  }

  String _buildPrompt(
    JobModel job,
    CandidateSupabaseModel candidate,
    String coverLetter,
  ) {
    final profileSkills = candidate.skillList.join(', ');
    final profileExperiences =
        candidate.experiences
            ?.map((e) => '${e.position} at ${e.companyName} (${e.period})')
            .join('; ') ??
        '';

    return '''
Bạn là một trợ lý tuyển dụng AI.
Hãy phân tích CV PDF đính kèm so với công việc mục tiêu.
Chỉ trả về JSON hợp lệ theo đúng schema, không thêm bất kỳ văn bản nào bên ngoài JSON.
Tên các field JSON phải giữ nguyên bằng tiếng Anh như schema, nhưng toàn bộ giá trị text bên trong phải viết bằng tiếng Việt tự nhiên.

Thông tin công việc:
- Tiêu đề: ${job.title}
- Công ty: ${job.company}
- Địa điểm: ${job.location}
- Loại hình: ${job.type}
- Mức lương: ${job.formattedSalary}
- Mô tả: ${job.description ?? ''}
- Yêu cầu: ${(job.requirements ?? const <String>[]).join('; ')}
- Từ khóa: ${(job.tags ?? const <String>[]).join(', ')}

Thông tin ứng viên:
- Họ tên: ${candidate.displayName}
- Tiêu đề hồ sơ: ${candidate.displayHeadline}
- Tóm tắt: ${candidate.displaySummary}
- Kỹ năng: $profileSkills
- Kinh nghiệm: $profileExperiences
- Học vấn: ${candidate.displayEducation}
- Cover letter: $coverLetter

Quy tắc chấm điểm:
- matchScore là số nguyên từ 0 đến 100.
- strengths: bằng chứng nổi bật trong CV phù hợp với job.
- gaps: kỹ năng/kinh nghiệm còn thiếu so với yêu cầu.
- suggestions: gợi ý cải thiện CV cụ thể cho job này.
- coverLetterTips: 3-5 gợi ý chỉnh cover letter.
- riskFlags: các điểm cần nhà tuyển dụng xác minh thêm khi phỏng vấn.
''';
  }

  Map<String, dynamic> _responseSchema() {
    return {
      'type': 'object',
      'properties': {
        'matchScore': {'type': 'integer'},
        'summary': {'type': 'string'},
        'strengths': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'gaps': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'suggestions': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'coverLetterTips': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'riskFlags': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': [
        'matchScore',
        'summary',
        'strengths',
        'gaps',
        'suggestions',
        'coverLetterTips',
        'riskFlags',
      ],
    };
  }
}
