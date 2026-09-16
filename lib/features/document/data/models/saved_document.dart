import 'dart:convert';

/// Metadata for a locally saved scan document.
///
/// All path fields point to files on the device's local storage.
/// The [originalText] and [summaryText] fields are stored inline in
/// SharedPreferences so that the Files tab can show text previews
/// without reading files from disk.
class SavedDocument {
  const SavedDocument({
    required this.documentId,
    required this.documentTitle,
    required this.captureDate,
    this.imagePath,
    this.originalTextPath,
    this.originalPdfPath,
    this.summaryTextPath,
    this.summaryPdfPath,
    this.originalAudioPath,
    this.summaryAudioPath,
    required this.originalText,
    required this.summaryText,
  });

  final String documentId;
  final String documentTitle;
  final DateTime captureDate;

  /// Local path to the JPEG captured image.
  final String? imagePath;

  /// Local path to the OCR text .txt file.
  final String? originalTextPath;

  /// Local path to the OCR text .pdf file.
  final String? originalPdfPath;

  /// Local path to the AI summary .txt file.
  final String? summaryTextPath;

  /// Local path to the AI summary .pdf file.
  final String? summaryPdfPath;

  /// Local path to the original espeak audio .wav file.
  final String? originalAudioPath;

  /// Local path to the summary espeak audio .wav file.
  final String? summaryAudioPath;

  /// The full OCR-extracted text (stored for quick preview).
  final String originalText;

  /// The full AI-generated summary (stored for quick preview).
  final String summaryText;

  // ─── Serialization ────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'documentTitle': documentTitle,
        'captureDate': captureDate.toIso8601String(),
        'imagePath': imagePath,
        'originalTextPath': originalTextPath,
        'originalPdfPath': originalPdfPath,
        'summaryTextPath': summaryTextPath,
        'summaryPdfPath': summaryPdfPath,
        'originalAudioPath': originalAudioPath,
        'summaryAudioPath': summaryAudioPath,
        'originalText': originalText,
        'summaryText': summaryText,
      };

  factory SavedDocument.fromJson(Map<String, dynamic> json) => SavedDocument(
        documentId: json['documentId'] as String,
        documentTitle: json['documentTitle'] as String,
        captureDate: DateTime.parse(json['captureDate'] as String),
        imagePath: json['imagePath'] as String?,
        originalTextPath: json['originalTextPath'] as String?,
        originalPdfPath: json['originalPdfPath'] as String?,
        summaryTextPath: json['summaryTextPath'] as String?,
        summaryPdfPath: json['summaryPdfPath'] as String?,
        originalAudioPath: json['originalAudioPath'] as String?,
        summaryAudioPath: json['summaryAudioPath'] as String?,
        originalText: json['originalText'] as String? ?? '',
        summaryText: json['summaryText'] as String? ?? '',
      );

  String toJsonString() => jsonEncode(toJson());

  static SavedDocument fromJsonString(String source) =>
      SavedDocument.fromJson(jsonDecode(source) as Map<String, dynamic>);

  // ─── Helpers ──────────────────────────────────────────────────────

  /// Short excerpt of the original text for list previews.
  String get textPreview {
    final trimmed = originalText.trim();
    if (trimmed.length <= 120) return trimmed;
    return '${trimmed.substring(0, 120)}…';
  }
}
