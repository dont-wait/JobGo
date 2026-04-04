/// Job categories constants for employer job posting
class JobCategories {
  /// List of all available job categories in the marketplace
  static const List<String> allCategories = [
    'Software Development',
    'Design & Creative',
    'Product Management',
    'Data Science & Analytics',
    'DevOps & Infrastructure',
    'Marketing & Growth',
    'Sales & Business Development',
    'Human Resources',
    'Finance & Accounting',
    'Operations & Administration',
  ];

  /// Default category selection placeholder
  static const String defaultCategory = 'Select Category';

  /// All categories including the default placeholder
  static List<String> get categoriesWithDefault => [
    defaultCategory,
    ...allCategories,
  ];
}
