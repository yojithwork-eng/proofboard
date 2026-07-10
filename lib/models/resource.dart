import 'app_mode.dart';

class Resource {
  const Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.relatedSkillName,
    required this.mode,
  });

  final String id;
  final String title;
  final String description;
  final String url;
  final String relatedSkillName;
  final AppMode mode;
}

const proofBoardResources = [
  Resource(
    id: 'coding_consistency',
    title: 'How to practice coding consistently',
    description:
        'Simple ways to turn small coding sessions into real progress.',
    url:
        'https://www.freecodecamp.org/news/how-to-stay-consistent-learning-code/',
    relatedSkillName: 'Coding',
    mode: AppMode.general,
  ),
  Resource(
    id: 'portfolio_projects',
    title: 'Build a stronger project portfolio',
    description: 'Ideas for turning practice work into proof you can show.',
    url:
        'https://www.freecodecamp.org/news/build-a-portfolio-that-gets-you-hired/',
    relatedSkillName: 'Projects',
    mode: AppMode.general,
  ),
  Resource(
    id: 'deep_work_focus',
    title: 'How to focus better',
    description: 'A beginner-friendly guide to protecting deep work time.',
    url: 'https://todoist.com/productivity-methods/deep-work',
    relatedSkillName: 'Deep Work',
    mode: AppMode.productivity,
  ),
  Resource(
    id: 'study_productivity',
    title: 'Study productivity tips',
    description:
        'Practical study habits for longer attention and better recall.',
    url:
        'https://learningcenter.unc.edu/tips-and-tools/studying-101-study-smarter-not-harder/',
    relatedSkillName: 'Studying',
    mode: AppMode.productivity,
  ),
  Resource(
    id: 'job_app_tracking',
    title: 'Track job applications like a project',
    description: 'A simple approach to staying organized while applying.',
    url: 'https://www.themuse.com/advice/job-application-tracker',
    relatedSkillName: 'Job Applications',
    mode: AppMode.productivity,
  ),
  Resource(
    id: 'sleep_habits',
    title: 'Sleep tips and habits',
    description: 'Healthy sleep basics for more consistent energy.',
    url: 'https://www.sleepfoundation.org/sleep-hygiene',
    relatedSkillName: 'Sleep',
    mode: AppMode.selfImprovement,
  ),
  Resource(
    id: 'sleep_schedule',
    title: 'Build a consistent sleep schedule',
    description: 'A simple guide for making sleep timing more reliable.',
    url: 'https://www.cdc.gov/sleep/about_sleep/sleep_hygiene.html',
    relatedSkillName: 'Sleep',
    mode: AppMode.selfImprovement,
  ),
  Resource(
    id: 'beginner_exercise',
    title: 'Beginner exercise habit guide',
    description: 'Start small with approachable movement and habit cues.',
    url:
        'https://www.healthline.com/health/fitness-exercise/10-best-exercises-everyday',
    relatedSkillName: 'Exercise',
    mode: AppMode.selfImprovement,
  ),
];

List<Resource> resourcesForMode(AppMode mode) {
  return proofBoardResources
      .where((resource) => resource.mode == mode)
      .toList(growable: false);
}
