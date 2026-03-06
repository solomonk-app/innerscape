class TagCategory {
  final String name;
  final String icon;
  final List<String> tags;

  const TagCategory({
    required this.name,
    required this.icon,
    required this.tags,
  });
}

const List<TagCategory> tagCategories = [
  TagCategory(
    name: 'Activity',
    icon: '🏃',
    tags: ['Exercise', 'Work', 'Social', 'Nature', 'Reading', 'Cooking', 'Creative', 'Rest'],
  ),
  TagCategory(
    name: 'People',
    icon: '👥',
    tags: ['Alone', 'Family', 'Friends', 'Partner', 'Colleagues'],
  ),
  TagCategory(
    name: 'Location',
    icon: '📍',
    tags: ['Home', 'Office', 'Outdoors', 'Cafe', 'Gym', 'Transit'],
  ),
];

List<String> get allTags =>
    tagCategories.expand((c) => c.tags).toList();
