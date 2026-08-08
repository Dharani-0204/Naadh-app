class DocumentOutput {
  const DocumentOutput({
    required this.originalText,
    required this.summaryText,
    required this.originalAudioDuration,
    required this.summaryAudioDuration,
  });

  final String originalText;
  final String summaryText;
  final Duration originalAudioDuration;
  final Duration summaryAudioDuration;
}
