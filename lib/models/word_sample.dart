class WordSample {
  final int? wordSamplesId;
  final int wordId;
  final String sample;
  final DateTime? createdAt;

  const WordSample({
    this.wordSamplesId,
    required this.wordId,
    required this.sample,
    this.createdAt,
  });

  factory WordSample.fromJson(Map<String, dynamic> json) {
    return WordSample(
      wordSamplesId: json['word_sample_id'] as int?,
      wordId: (json['word_id'] as int?) ?? 0,
      sample: (json['sample'] as String?) ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (wordSamplesId != null) 'word_sample_id': wordSamplesId,
        'word_id': wordId,
        'sample': sample,
      };
}
