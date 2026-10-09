class PreparationPreference {
  final String id;
  final String preferenceType; // e.g., 'language', 'studyPattern', 'sessionPattern', 'practiceStyle'
  final String title;
  final String description;
  final String observationSource;
  final bool isUserControlled;

  PreparationPreference({
    required this.id,
    required this.preferenceType,
    required this.title,
    required this.description,
    required this.observationSource,
    this.isUserControlled = false,
  });
}

final List<PreparationPreference> dummyPreferences = [
  PreparationPreference(
    id: 'p_1',
    preferenceType: 'language',
    title: 'Tamil',
    description: 'Based on your selected preference.',
    observationSource: 'Explicit Settings',
    isUserControlled: true,
  ),
  PreparationPreference(
    id: 'p_2',
    preferenceType: 'studyPattern',
    title: 'Evening Sessions',
    description: 'You frequently study in the evening.',
    observationSource: 'Observed from your recent completed study sessions.',
  ),
  PreparationPreference(
    id: 'p_3',
    preferenceType: 'practiceStyle',
    title: 'Topic-focused',
    description: 'You frequently practice by topic.',
    observationSource: 'Observed from your practice history.',
  ),
  PreparationPreference(
    id: 'p_4',
    preferenceType: 'sessionPattern',
    title: 'Short focused sessions',
    description: 'Most completed sessions are under 30 minutes.',
    observationSource: 'Observed from study planner records.',
  ),
];
