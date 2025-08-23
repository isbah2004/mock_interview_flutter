class AIResponseCleaner {
  static String removeBackquotes(String text) {
    return text.replaceAll(RegExp(r'`+'), '');
  }

  static String cleanAIResponse(String text) {
    String cleanedText = text;
    cleanedText = cleanedText.replaceAll(RegExp(r'`+'), '');

    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => match.group(1)!,
    );

    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
      (match) => match.group(1)!,
    );

    cleanedText = cleanedText.replaceAll(RegExp(r'\*+'), '');

    cleanedText = cleanedText.replaceAll(RegExp(r'`+'), '');

    cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ');

    cleanedText = cleanedText.trim();

    return cleanedText;
  }

  static String removeBackquotesOnly(String text) {
    return text.replaceAll(RegExp(r'`'), '');
  }

  static String removeAsterisksAndBackquotes(String text) {
    String cleanedText = text;

    cleanedText = cleanedText.replaceAll(RegExp(r'\*+'), '');

    cleanedText = cleanedText.replaceAll(RegExp(r'`+'), '');

    cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ');

    cleanedText = cleanedText.trim();

    return cleanedText;
  }
}
