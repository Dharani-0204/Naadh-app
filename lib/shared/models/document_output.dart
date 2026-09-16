class DocumentOutput {
  const DocumentOutput({
    required this.originalText,
    required this.summaryText,
    this.imageUrl,
    this.originalAudioUrl,
    this.summaryAudioUrl,
  });

  /// The raw OCR-extracted text from the captured document.
  final String originalText;

  /// The AI-generated (Gemini) summary of the document.
  final String summaryText;

  /// Full URL to the captured document image served by the Pi backend.
  /// e.g. http://192.168.0.134:8000/capture/1/image
  final String? imageUrl;

  /// Full URL to the WAV audio file of the original text (espeak).
  final String? originalAudioUrl;

  /// Full URL to the WAV audio file of the summary (espeak).
  final String? summaryAudioUrl;
}
