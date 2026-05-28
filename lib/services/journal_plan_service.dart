import '../constants/journal_plans.dart';
import '../models/journal_plan.dart';
import 'storage_service.dart';

class JournalPlanService {
  static final JournalPlanService _instance = JournalPlanService._();
  factory JournalPlanService() => _instance;
  JournalPlanService._();

  Future<List<JournalPlanProgress>> getAll() async {
    final storage = await StorageService.getInstance();
    return storage.getPlanProgress();
  }

  Future<List<JournalPlanProgress>> getActive() async {
    final all = await getAll();
    return all.where((p) => !p.archived).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  Future<List<JournalPlanProgress>> getArchived() async {
    final all = await getAll();
    return all.where((p) => p.archived).toList()
      ..sort((a, b) =>
          (b.archivedAt ?? b.startedAt).compareTo(a.archivedAt ?? a.startedAt));
  }

  Future<JournalPlanProgress?> getById(String planId) async {
    final all = await getAll();
    for (final p in all) {
      if (p.planId == planId && !p.archived) return p;
    }
    return null;
  }

  /// Returns true if a non-archived plan with this templateId already exists.
  Future<bool> hasActive(String templateId) async {
    final active = await getActive();
    return active.any((p) => p.planId == templateId);
  }

  /// Start a plan. Rejects if the same template is already active.
  Future<JournalPlanProgress?> startPlan(String templateId) async {
    if (planTemplateById(templateId) == null) return null;
    if (await hasActive(templateId)) return null;

    final all = await getAll();
    final progress = JournalPlanProgress(
      planId: templateId,
      startedAt: DateTime.now(),
    );
    all.add(progress);
    final storage = await StorageService.getInstance();
    await storage.savePlanProgress(all);
    return progress;
  }

  Future<JournalPlanProgress?> markDayComplete({
    required String planId,
    required int day,
  }) async {
    final all = await getAll();
    final index = all.indexWhere((p) => p.planId == planId && !p.archived);
    if (index < 0) return null;

    final current = all[index];
    if (current.completedDays.containsKey(day)) return current;

    final updated = current.copyWith(
      completedDays: {...current.completedDays, day: DateTime.now()},
    );
    all[index] = updated;
    final storage = await StorageService.getInstance();
    await storage.savePlanProgress(all);
    return updated;
  }

  Future<JournalPlanProgress?> archive(String planId) async {
    final all = await getAll();
    final index = all.indexWhere((p) => p.planId == planId && !p.archived);
    if (index < 0) return null;

    final updated = all[index].copyWith(
      archived: true,
      archivedAt: DateTime.now(),
    );
    all[index] = updated;
    final storage = await StorageService.getInstance();
    await storage.savePlanProgress(all);
    return updated;
  }

  /// First uncompleted day (1-based), or null if the plan is complete.
  int? currentDay(JournalPlanProgress progress, JournalPlanTemplate template) {
    for (int d = 1; d <= template.lengthDays; d++) {
      if (!progress.completedDays.containsKey(d)) return d;
    }
    return null;
  }

  bool isComplete(JournalPlanProgress progress, JournalPlanTemplate template) =>
      progress.completedDays.length >= template.lengthDays;

  double progressFraction(
    JournalPlanProgress progress,
    JournalPlanTemplate template,
  ) {
    if (template.lengthDays == 0) return 0;
    return (progress.completedDays.length / template.lengthDays).clamp(0.0, 1.0);
  }

  String promptKey(String planId, int day) => 'plan:$planId:day$day';
}
