import JSZip from 'npm:jszip@3.10.1';

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
  const cvFormat = detectCvFormat(cvUrl);
  if (cvFormat == null) {
    return jsonResponse({ error: 'AI analysis supports PDF, DOCX, TXT only.' }, 400);
  }
  try {
    new URL(cvUrl);
  } catch {
    return jsonResponse({ error: 'Invalid CV URL' }, 400);
  }

  const languageCode = normalizeLanguageCode(body.languageCode);
  const model = (body.model?.trim() || Deno.env.get('GEMINI_MODEL')?.trim() || DEFAULT_MODEL).trim();

  try {
    const file = await downloadCvDocument(cvUrl);
    const fileBytes = file.bytes;
    const prompt = await buildPrompt(body, languageCode, cvFormat, fileBytes);
    const parts: Record<string, unknown>[] = [{ text: prompt }];
    if (cvFormat === 'pdf') {
      if (!looksLikePdf(fileBytes)) {
        throw new Error(
          `CV URL did not return a valid PDF file. content-type=${file.contentType || 'unknown'}, first-bytes=${previewBytes(fileBytes)}`,
        );
      }
      parts.push({
        inline_data: {
          mime_type: 'application/pdf',
          data: bytesToBase64(fileBytes),
        },
      });
    }

    const geminiResponse = await requestGemini({
      apiKey,
      model,
      parts,
    });

    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text();
      console.error(
        `Gemini request failed: ${geminiResponse.status} ${geminiResponse.statusText} ${errorText}`,
      );
      return jsonResponse(
        {
          error: 'Gemini request failed',
          status: geminiResponse.status,
          detail: summarizeErrorText(errorText),
        },
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
    const detail = error instanceof Error ? error.message : String(error);
    console.error('AI analysis failed:', detail);
    return jsonResponse(
      { error: 'AI analysis failed', detail },
      500,
    );
  }
});

async function buildPrompt(
  body: AnalysisRequest,
  languageCode: string,
  cvFormat: SupportedCvFormat,
  fileBytes: Uint8Array,
): Promise<string> {
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
  const cvTextBlock = cvFormat === 'pdf'
    ? ''
    : await buildExtractedCvTextBlock(cvFormat, fileBytes);

  if (languageCode === 'en') {
    return `
You are an AI hiring assistant.
Analyze the provided CV against the target job.
Return valid JSON only, matching the schema exactly. Do not add any text outside the JSON.
Keep the JSON field names in English as specified, but write all text values naturally in English.
Be concise and outline-style:
- summary: 1 short sentence.
- strengths, gaps, suggestions, coverLetterTips, riskFlags: 2-4 short bullet-like phrases each.
- Each array item must be under 18 words.
- Avoid long explanations, repeated points, and generic advice.

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
${cvTextBlock}

Scoring rules:
- matchScore must be an integer from 0 to 100.
- strengths: concise evidence from the CV relevant to the job.
- gaps: concise missing skills or experience relative to the requirements.
- suggestions: concise CV improvements tailored to this job.
- coverLetterTips: 2-4 concise improvement tips.
- riskFlags: concise concerns the recruiter should verify in interview.
`.trim();
  }

  return `
Bạn là một trợ lý tuyển dụng AI.
Hãy phân tích CV được cung cấp so với công việc mục tiêu.
Chỉ trả về JSON hợp lệ theo đúng schema, không thêm bất kỳ văn bản nào bên ngoài JSON.
Tên các field JSON phải giữ nguyên bằng tiếng Anh như schema, nhưng toàn bộ giá trị text bên trong phải viết bằng tiếng Việt tự nhiên.
Viết ngắn gọn theo dạng outline:
- summary: 1 câu ngắn.
- strengths, gaps, suggestions, coverLetterTips, riskFlags: mỗi mục 2-4 ý ngắn.
- Mỗi item trong array tối đa 18 từ.
- Tránh giải thích dài, lặp ý, hoặc lời khuyên chung chung.

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
${cvTextBlock}

Quy tắc chấm điểm:
- matchScore là số nguyên từ 0 đến 100.
- strengths: bằng chứng ngắn gọn trong CV phù hợp với job.
- gaps: kỹ năng/kinh nghiệm còn thiếu, viết ngắn gọn.
- suggestions: gợi ý cải thiện CV cụ thể, viết ngắn gọn.
- coverLetterTips: 2-4 gợi ý chỉnh cover letter.
- riskFlags: điểm cần nhà tuyển dụng xác minh thêm khi phỏng vấn.
`.trim();
}

type DownloadedCvDocument = {
  bytes: Uint8Array;
  contentType: string;
};

async function downloadCvDocument(cvUrl: string): Promise<DownloadedCvDocument> {
  const response = await fetch(cvUrl, { method: 'GET', redirect: 'follow' });
  if (!response.ok) {
    throw new Error(`Failed to download CV: ${response.status}`);
  }

  const contentType = response.headers.get('content-type') ?? '';
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
  return { bytes, contentType };
}

function looksLikePdf(bytes: Uint8Array): boolean {
  let offset = 0;
  while (
    offset < bytes.length &&
    (bytes[offset] === 0x09 ||
      bytes[offset] === 0x0a ||
      bytes[offset] === 0x0d ||
      bytes[offset] === 0x20)
  ) {
    offset++;
  }

  return (
    bytes.length >= offset + 5 &&
    bytes[offset] === 0x25 &&
    bytes[offset + 1] === 0x50 &&
    bytes[offset + 2] === 0x44 &&
    bytes[offset + 3] === 0x46 &&
    bytes[offset + 4] === 0x2d
  );
}

type SupportedCvFormat = 'pdf' | 'docx' | 'txt';

function detectCvFormat(url: string): SupportedCvFormat | null {
  const lower = url.toLowerCase().trim();
  if (lower.length === 0) return null;
  const normalized = lower.split('?')[0].split('#')[0];
  if (normalized.endsWith('.pdf')) return 'pdf';
  if (normalized.endsWith('.docx')) return 'docx';
  if (normalized.endsWith('.txt')) return 'txt';
  return null;
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

async function requestGemini({
  apiKey,
  model,
  parts,
}: {
  apiKey: string;
  model: string;
  parts: Record<string, unknown>[];
}): Promise<Response> {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`;
  const requestInit: RequestInit = {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    },
    body: JSON.stringify({
      contents: [
        {
          role: 'user',
          parts,
        },
      ],
      generationConfig: {
        temperature: 0.2,
        responseMimeType: 'application/json',
        responseJsonSchema: responseSchema(),
      },
    }),
  };

  let response = await fetch(url, requestInit);
  for (let attempt = 1; attempt <= 2 && isRetryableGeminiStatus(response.status); attempt++) {
    await delay(350 * attempt);
    response = await fetch(url, requestInit);
  }
  return response;
}

function isRetryableGeminiStatus(status: number): boolean {
  return status === 429 || status === 500 || status === 502 || status === 503 || status === 504;
}

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function summarizeErrorText(text: string): string {
  const trimmed = text.trim();
  return trimmed.length > 500 ? `${trimmed.slice(0, 500)}...` : trimmed;
}

function previewBytes(bytes: Uint8Array): string {
  return Array.from(bytes.slice(0, 12))
    .map((byte) => byte.toString(16).padStart(2, '0'))
    .join(' ');
}

async function buildExtractedCvTextBlock(
  format: Exclude<SupportedCvFormat, 'pdf'>,
  bytes: Uint8Array,
): Promise<string> {
  let extracted = '';
  if (format === 'txt') {
    extracted = decodeTextFile(bytes);
  } else {
    extracted = await extractDocxText(bytes);
  }
  const cleaned = extracted.trim().replace(/\s+/g, ' ');
  if (!cleaned) {
    throw new Error('CV content is empty or unreadable');
  }
  const truncated = cleaned.slice(0, 18000);
  return `\nCandidate CV content (extracted plain text):\n${truncated}\n`;
}

function decodeTextFile(bytes: Uint8Array): string {
  try {
    return new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch {
    return new TextDecoder('utf-8').decode(bytes);
  }
}

async function extractDocxText(bytes: Uint8Array): Promise<string> {
  if (!looksLikeZip(bytes)) {
    throw new Error('Invalid DOCX file');
  }

  const zip = await JSZip.loadAsync(bytes);
  const files = [
    'word/document.xml',
    'word/header1.xml',
    'word/header2.xml',
    'word/footer1.xml',
    'word/footer2.xml',
  ];
  const texts: string[] = [];

  for (const file of files) {
    const xml = await zip.file(file)?.async('string');
    if (xml && xml.trim().length > 0) {
      texts.push(xmlToText(xml));
    }
  }

  return texts.join('\n').trim();
}

function looksLikeZip(bytes: Uint8Array): boolean {
  return bytes.length >= 4 &&
    bytes[0] === 0x50 &&
    bytes[1] === 0x4b &&
    (bytes[2] === 0x03 || bytes[2] === 0x05 || bytes[2] === 0x07) &&
    (bytes[3] === 0x04 || bytes[3] === 0x06 || bytes[3] === 0x08);
}

function xmlToText(xml: string): string {
  return xml
    .replace(/<w:tab\/>/g, '\t')
    .replace(/<w:br\/>/g, '\n')
    .replace(/<\/w:p>/g, '\n')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/\s+\n/g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
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
