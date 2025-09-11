class AIResponseCleaner {
  static String removeBackquotes(String text) {
    return text.replaceAll(RegExp(r'`+'), '');
  }

  static String cleanAIResponse(String text) {
    String cleanedText = text;

    // Remove all types of backticks (single, double, triple, etc.)
    cleanedText = cleanedText.replaceAll(RegExp(r'`+'), '');

    // Remove bold formatting (**text**)
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => match.group(1)!,
    );

    // Remove italic formatting (*text*)
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'(?<!\*)\*([^*]+)\*(?!\*)'),
      (match) => match.group(1)!,
    );

    // Remove any remaining asterisks
    cleanedText = cleanedText.replaceAll(RegExp(r'\*+'), '');

    // Remove underscores used for emphasis
    cleanedText = cleanedText.replaceAll(RegExp(r'_+'), '');

    // Remove hash symbols used for headers
    cleanedText = cleanedText.replaceAll(RegExp(r'#+\s*'), '');

    // Remove square brackets used for links [text] but keep the text
    cleanedText = cleanedText.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]'),
      (match) => match.group(1)!,
    );

    // Remove URLs in parentheses (commonly found after link text)
    cleanedText = cleanedText.replaceAll(RegExp(r'\(https?://[^\s\)]+\)'), '');

    // Replace multiple spaces with single space
    cleanedText = cleanedText.replaceAll(RegExp(r'\s+'), ' ');

    // Clean up common markdown punctuation that sounds bad in TTS
    cleanedText = cleanedText.replaceAll(
      RegExp(r'---+'),
      ' ',
    ); // Remove horizontal rules
    cleanedText = cleanedText.replaceAll(
      RegExp(r'===+'),
      ' ',
    ); // Remove headers underlines

    // Remove or replace other symbols that don't read well
    cleanedText = cleanedText.replaceAll('>', ''); // Remove quote markers
    cleanedText = cleanedText.replaceAll('<', ''); // Remove HTML-like brackets

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
