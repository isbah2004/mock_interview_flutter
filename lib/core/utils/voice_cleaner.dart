class VoiceCleaner {
  /// Cleans and normalizes voice input text
  static String cleanVoiceInput(String input) {
    if (input.isEmpty) return input;

    // Remove extra whitespace
    String cleaned = input.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Remove common speech-to-text artifacts
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(um|uh|ah|er|hmm)\b', caseSensitive: false),
      '',
    );

    // Remove repeated words (common in speech recognition)
    cleaned = _removeRepeatedWords(cleaned);

    // Capitalize first letter of sentences
    cleaned = _capitalizeSentences(cleaned);

    // Clean up punctuation
    cleaned = _cleanPunctuation(cleaned);

    // Remove extra whitespace again after cleaning
    cleaned = cleaned.trim().replaceAll(RegExp(r'\s+'), ' ');

    return cleaned;
  }

  /// Removes repeated consecutive words
  static String _removeRepeatedWords(String text) {
    List<String> words = text.split(' ');
    List<String> cleanedWords = [];

    for (int i = 0; i < words.length; i++) {
      String currentWord = words[i].toLowerCase();

      // Skip if it's the same as the previous word (case-insensitive)
      if (i > 0 && currentWord == words[i - 1].toLowerCase()) {
        continue;
      }

      cleanedWords.add(words[i]);
    }

    return cleanedWords.join(' ');
  }

  /// Capitalizes the first letter of sentences
  static String _capitalizeSentences(String text) {
    if (text.isEmpty) return text;

    // Split by sentence endings
    List<String> sentences = text.split(RegExp(r'[.!?]'));
    List<String> capitalizedSentences = [];

    for (String sentence in sentences) {
      String trimmed = sentence.trim();
      if (trimmed.isNotEmpty) {
        String capitalized = trimmed[0].toUpperCase() + trimmed.substring(1);
        capitalizedSentences.add(capitalized);
      }
    }

    // If no sentence endings found, just capitalize the first letter
    if (capitalizedSentences.isEmpty) {
      return text[0].toUpperCase() + text.substring(1);
    }

    return capitalizedSentences.join('. ');
  }

  /// Cleans up punctuation
  static String _cleanPunctuation(String text) {
    // Remove multiple consecutive punctuation marks
    text = text.replaceAll(RegExp(r'[.]{2,}'), '.');
    text = text.replaceAll(RegExp(r'[!]{2,}'), '!');
    text = text.replaceAll(RegExp(r'[?]{2,}'), '?');
    text = text.replaceAll(RegExp(r'[,]{2,}'), ',');

    // Remove spaces before punctuation
    text = text.replaceAll(RegExp(r'\s+([.!?,:;])'), r'$1');

    // Ensure space after punctuation (except at end of string)
    text = text.replaceAll(RegExp(r'([.!?,:;])([^\s])'), r'$1 $2');

    return text;
  }

  /// Validates if the cleaned input is meaningful
  static bool isValidInput(String cleanedInput) {
    if (cleanedInput.trim().isEmpty) return false;

    // Check if it has at least 2 characters and isn't just punctuation
    String alphanumeric = cleanedInput.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return alphanumeric.length >= 2;
  }

  /// Cleans AI response text by removing markdown formatting
  static String cleanAiResponse(String response) {
    if (response.isEmpty) return response;

    String cleaned = response;

    // Remove markdown bold formatting (**text**)
    cleaned = cleaned.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');

    // Remove markdown italic formatting (*text* or _text_)
    cleaned = cleaned.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'_(.*?)_'), r'$1');

    // Remove markdown code formatting (`text`)
    cleaned = cleaned.replaceAll(RegExp(r'`(.*?)`'), r'$1');

    // Remove standalone asterisks that might be left over
    cleaned = cleaned.replaceAll(RegExp(r'\*+'), '');

    // Clean up extra whitespace
    cleaned = cleaned.trim().replaceAll(RegExp(r'\s+'), ' ');

    return cleaned;
  }

  /// Gets confidence score for the cleaned input (0.0 to 1.0)
  static double getConfidenceScore(String originalInput, String cleanedInput) {
    if (originalInput.isEmpty) return 0.0;

    // Base confidence on length ratio and word count
    double lengthRatio = cleanedInput.length / originalInput.length;
    int wordCount =
        cleanedInput.split(' ').where((word) => word.isNotEmpty).length;

    // Higher confidence for longer, more complete responses
    double wordScore = (wordCount / 10).clamp(
      0.0,
      1.0,
    ); // Max score at 10+ words
    double lengthScore = lengthRatio.clamp(
      0.3,
      1.0,
    ); // Penalize if too much was removed

    return (wordScore * 0.6 + lengthScore * 0.4).clamp(0.0, 1.0);
  }
}
