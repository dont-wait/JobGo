const DEFAULT_MODEL = 'gemini-2.5-flash';
const MAX_PDF_BYTES = 10 * 1024 * 1024;
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

type AnalysisRequest = {
  applicationId?: number | null;
  jobId?: number | null;
  candidateId?: number | null;
  cvUrl?: string | null;
  coverLetter?: string | null;
  languageCode?: string | null;
  model?: string | null;
  job?: {
    title?: string | null;
    company?: string | null;
    location?: string | null;
    type?: string | null;
    salary?: string | null;
    description?: string | null;
    requirements?: string[] | null;
    tags?: string[] | null;
  };
  candidate?: {
    displayName?: string | null;
    displayHeadline?: string | null;
    displaySummary?: string | null;
    displayEducation?: string | null;
    displayLocation?: string | null;
    displayPhone?: string | null;
    displayEmail?: string | null;
    skillList?: string[] | null;
    experiences?: Array<{
      position?: string | null;
      companyName?: string | null;
      period?: string | null;
      description?: string | null;
    }> | null;
  };
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405);
  }

  const apiKey = Deno.env.get('GEMINI_API_KEY')?.trim() ?? '';
  if (!apiKey) {
    return jsonResponse({ error: 'Missing GEMINI_API_KEY secret' }, 500);
  }

  let body: AnalysisRequest;
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON payload' }, 400);
  }

  const cvUrl = body.cvUrl?.trim() ?? '';
  if (!cvUrl) {
    return jsonResponse({ error: 'Missing cvUrl' }, 400);
  }
  if (!isPdfUrl(cvUrl)) {
    return jsonResponse({ error: 'AI analysis supports PDF only for now.' }, 400);
  }
  try {
    new URL(cvUrl);
  } catch {
    return jsonResponse({ error: 'Invalid CV URL' }, 400);
  }

  const languageCode = normalizeLanguageCode(body.languageCode);
  const model = (body.model?.trim() || Deno.env.get('GEMINI_MODEL')?.trim() || DEFAULT_MODEL).trim();

  try {
    const pdfBytes = await downloadPdf(cvUrl);
    const prompt = buildPrompt(body, languageCode);
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: JSON.stringify({
          contents: [
            {
              role: 'user',
              parts: [
                { text: prompt },
                {
                  inline_data: {
                    mime_type: 'application/pdf',
                    data: bytesToBase64(pdfBytes),
                  },
                },
              ],
            },
          ],
          generationConfig: {
            temperature: 0.2,
            responseMimeType: 'application/json',
            responseJsonSchema: responseSchema(),
          },
        }),
      },
    );

    if (!geminiResponse.ok) {
      console.error(
        `Gemini request failed: ${geminiResponse.status} ${geminiResponse.statusText}`,
      );
      return jsonResponse(
        { error: 'Gemini request failed', status: geminiResponse.status },
        502,
      );
    }

    const jsonBody = await geminiResponse.json();
    const text = extractGeminiText(jsonBody);
    const structured = JSON.parse(normalizeJson(text));

    return jsonResponse({
      ...structured,
      model,
      languageCode,
    });
  } catch (error) {
    console.error('AI analysis failed:', error instanceof Error ? error.message : error);
    return jsonResponse(
      { error: 'AI analysis failed' },
      500,
    );
  }
});

function buildPrompt(body: AnalysisRequest, languageCode: string): string {
  const job = body.job ?? {};
  const candidate = body.candidate ?? {};
  const profileSkills = (candidate.skillList ?? []).join(', ');
  const profileExperiences = (candidate.experiences ?? [])
    .map((experience) => {
      const parts: string[] = [];
      if (experience.position?.trim()) parts.push(experience.position.trim());
      if (experience.companyName?.trim()) {
        parts.push(`at ${experience.companyName.trim()}`);
      }
      if (experience.period?.trim()) parts.push(`(${experience.period.trim()})`);
      return parts.join(' ');
    })
    .join('; ');
  const coverLetter = body.coverLetter?.trim() ?? '';

  if (languageCode === 'en') {
    return `
You are an AI hiring assistant.
Analyze the attached PDF CV against the target job.
Return valid JSON only, matching the schema exactly. Do not add any text outside the JSON.
Keep the JSON field names in English as specified, but write all text values naturally in English.

Target Job:
- Title: ${job.title ?? ''}
- Company: ${job.company ?? ''}
- Location: ${job.location ?? ''}
- Job type: ${job.type ?? ''}
- Salary: ${job.salary ?? ''}
- Description: ${job.description ?? ''}
- Requirements: ${(job.requirements ?? []).join('; ')}
- Tags: ${(job.tags ?? []).join(', ')}

Candidate Profile:
- Name: ${candidate.displayName ?? ''}
- Headline: ${candidate.displayHeadline ?? ''}
- Summary: ${candidate.displaySummary ?? ''}
- Skills: ${profileSkills}
- Experience: ${profileExperiences}
- Education: ${candidate.displayEducation ?? ''}
- Cover letter: ${coverLetter}

Scoring rules:
- matchScore must be an integer from 0 to 100.
- strengths: evidence from the CV relevant to the job.
- gaps: missing skills or experience relative to the requirements.
- suggestions: concrete CV improvements tailored to this job.
- coverLetterTips: 3-5 specific improvement tips.
- riskFlags: concerns the recruiter should verify in interview.
`.trim();
  }

  return `
Bạn là một trợ lý tuyển dụng AI.
Hãy phân tích CV PDF đính kèm so với công việc mục tiêu.
Chỉ trả về JSON hợp lệ theo đúng schema, không thêm bất kỳ văn bản nào bên ngoài JSON.
Tên các field JSON phải giữ nguyên bằng tiếng Anh như schema, nhưng toàn bộ giá trị text bên trong phải viết bằng tiếng Việt tự nhiên.

Thông tin công việc:
- Tiêu đề: ${job.title ?? ''}
- Công ty: ${job.company ?? ''}
- Địa điểm: ${job.location ?? ''}
- Loại hình: ${job.type ?? ''}
- Mức lương: ${job.salary ?? ''}
- Mô tả: ${job.description ?? ''}
- Yêu cầu: ${(job.requirements ?? []).join('; ')}
- Từ khóa: ${(job.tags ?? []).join(', ')}

Thông tin ứng viên:
- Họ tên: ${candidate.displayName ?? ''}
- Tiêu đề hồ sơ: ${candidate.displayHeadline ?? ''}
- Tóm tắt: ${candidate.displaySummary ?? ''}
- Kỹ năng: ${profileSkills}
- Kinh nghiệm: ${profileExperiences}
- Học vấn: ${candidate.displayEducation ?? ''}
- Cover letter: ${coverLetter}

Quy tắc chấm điểm:
- matchScore là số nguyên từ 0 đến 100.
- strengths: bằng chứng nổi bật trong CV phù hợp với job.
- gaps: kỹ năng/kinh nghiệm còn thiếu so với yêu cầu.
- suggestions: gợi ý cải thiện CV cụ thể cho job này.
- coverLetterTips: 3-5 gợi ý chỉnh cover letter.
- riskFlags: các điểm cần nhà tuyển dụng xác minh thêm khi phỏng vấn.
`.trim();
}

async function downloadPdf(cvUrl: string): Promise<Uint8Array> {
  const response = await fetch(cvUrl, { method: 'GET', redirect: 'follow' });
  if (!response.ok) {
    throw new Error(`Failed to download CV: ${response.status}`);
  }

  const contentLength = Number(response.headers.get('content-length') ?? '0');
  if (contentLength > MAX_PDF_BYTES) {
    throw new Error('CV file is too large');
  }

  const bytes = new Uint8Array(await response.arrayBuffer());
  if (bytes.length === 0) {
    throw new Error('Downloaded CV is empty');
  }
  if (bytes.length > MAX_PDF_BYTES) {
    throw new Error('CV file is too large');
  }
  if (!looksLikePdf(bytes)) {
    throw new Error('Only PDF files are supported');
  }

  return bytes;
}

function looksLikePdf(bytes: Uint8Array): boolean {
  return (
    bytes.length >= 5 &&
    bytes[0] === 0x25 &&
    bytes[1] === 0x50 &&
    bytes[2] === 0x44 &&
    bytes[3] === 0x46 &&
    bytes[4] === 0x2d
  );
}

function isPdfUrl(url: string): boolean {
  const lower = url.toLowerCase().trim();
  if (lower.length === 0) return false;
  const normalized = lower.split('?')[0].split('#')[0];
  return normalized.endsWith('.pdf');
}

function normalizeLanguageCode(languageCode?: string | null): 'vi' | 'en' {
  const code = (languageCode ?? '').trim().toLowerCase();
  if (code.startsWith('vi')) return 'vi';
  return 'en';
}

function extractGeminiText(body: Record<string, unknown>): string {
  const candidates = body['candidates'];
  if (!Array.isArray(candidates) || candidates.length === 0) {
    throw new Error('Gemini returned no candidates');
  }

  const first = candidates[0] as Record<string, unknown> | undefined;
  const content = first?.['content'] as Record<string, unknown> | undefined;
  const parts = content?.['parts'];
  if (!Array.isArray(parts) || parts.length === 0) {
    throw new Error('Gemini parts are missing');
  }

  for (const part of parts) {
    if (part && typeof part === 'object') {
      const text = (part as Record<string, unknown>)['text'];
      if (typeof text === 'string') return text;
    }
  }

  throw new Error('Gemini text response is missing');
}

function normalizeJson(raw: string): string {
  let text = raw.trim();
  if (text.startsWith('```')) {
    text = text.replace(/^```(?:json)?\s*/i, '');
    text = text.replace(/\s*```$/i, '');
  }
  return text.trim();
}

function bytesToBase64(bytes: Uint8Array): string {
  let binary = '';
  const chunkSize = 0x2000;
  for (let i = 0; i < bytes.length; i += chunkSize) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunkSize));
  }
  return btoa(binary);
}

function responseSchema() {
  return {
    type: 'object',
    properties: {
      matchScore: { type: 'integer' },
      summary: { type: 'string' },
      strengths: { type: 'array', items: { type: 'string' } },
      gaps: { type: 'array', items: { type: 'string' } },
      suggestions: { type: 'array', items: { type: 'string' } },
      coverLetterTips: { type: 'array', items: { type: 'string' } },
      riskFlags: { type: 'array', items: { type: 'string' } },
    },
    required: [
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

function jsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...CORS_HEADERS,
      'Content-Type': 'application/json',
    },
  });
}
