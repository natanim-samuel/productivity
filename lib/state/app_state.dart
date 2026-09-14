import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Single source of truth for the whole app. Holds every list, persists to
/// SharedPreferences on every mutation, and exposes the derived views
/// (today/upcoming/overdue/streaks/stats) so screens never recompute their
/// own copy of the same logic — matches the "no repetition" design.
class AppState extends ChangeNotifier {
  static const _kTasks = 'tasks_v1';
  static const _kHabits = 'habits_v1';
  static const _kGoals = 'goals_v1';
  static const _kActivities = 'activities_v1';
  static const _kActiveDays = 'active_days_v1';
  static const _kChallengeStart = 'challenge_start_v1';

  List<Task> tasks = [];
  List<Habit> habits = [];
  List<Goal> goals = [];
  List<Activity> activities = [];
  Set<String> activeDays = {}; // ISO dates the user completed *something*
  late DateTime challengeStart;

  SharedPreferences? _prefs;
  bool loaded = false;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    tasks = _decodeList(_kTasks).map((e) => Task.fromJson(e)).toList();
    habits = _decodeList(_kHabits).map((e) => Habit.fromJson(e)).toList();
    goals = _decodeList(_kGoals).map((e) => Goal.fromJson(e)).toList();
    activities = _decodeList(_kActivities).map((e) => Activity.fromJson(e)).toList();
    activeDays = (_prefs!.getStringList(_kActiveDays) ?? []).toSet();
    final storedStart = _prefs!.getString(_kChallengeStart);
    challengeStart = storedStart != null ? DateTime.parse(storedStart) : DateTime.now();
    if (storedStart == null) await _prefs!.setString(_kChallengeStart, challengeStart.toIso8601String());

    if (tasks.isEmpty && habits.isEmpty && goals.isEmpty && activities.isEmpty) {
      _seedDemoData();
      await _persist();
    }
    loaded = true;
    notifyListeners();
  }

  List<Map<String, dynamic>> _decodeList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setString(_kTasks, jsonEncode(tasks.map((e) => e.toJson()).toList()));
    await _prefs!.setString(_kHabits, jsonEncode(habits.map((e) => e.toJson()).toList()));
    await _prefs!.setString(_kGoals, jsonEncode(goals.map((e) => e.toJson()).toList()));
    await _prefs!.setString(_kActivities, jsonEncode(activities.map((e) => e.toJson()).toList()));
    await _prefs!.setStringList(_kActiveDays, activeDays.toList());
  }

  void _markActiveToday() => activeDays.add(_isoDate(DateTime.now()));

  /// Consecutive-day streak of "did at least one thing" ending today.
  int get currentStreak {
    int streak = 0;
    var day = DateTime.now();
    while (activeDays.contains(_isoDate(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get dayOfChallenge => DateTime.now().difference(challengeStart).inDays.clamp(0, 99) + 1;
  double get challengeProgress => (dayOfChallenge / 100).clamp(0, 1);

  int get totalCompletedTasks => tasks.where((t) => t.completed).length;

  int get focusMinutesThisWeek => activities.fold(0, (sum, a) => sum + a.minutesThisWeek);
  String get focusTimeLabel {
    final m = focusMinutesThisWeek;
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }

  // ---------------- Tasks ----------------

  List<Task> get todayTasks {
    final now = DateTime.now();
    return tasks.where((t) => !t.isRecurring && t.due != null && _isSameDay(t.due!, now)).toList();
  }

  List<Task> get overdueTasks {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return tasks.where((t) => !t.isRecurring && !t.completed && t.due != null && t.due!.isBefore(startOfToday)).toList();
  }

  List<Task> get upcomingTasks {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return tasks.where((t) => !t.isRecurring && !t.completed && t.due != null && t.due!.isAfter(endOfToday)).toList();
  }

  List<Task> get completedTasks => tasks.where((t) => t.completed).toList();
  List<Task> get recurringTasks => tasks.where((t) => t.isRecurring).toList();

  void addTask(Task t) {
    tasks.add(t);
    _persist();
    notifyListeners();
  }

  void toggleTask(String id) {
    final t = tasks.firstWhere((e) => e.id == id);
    t.completed = !t.completed;
    if (t.completed) _markActiveToday();
    _persist();
    notifyListeners();
  }

  void deleteTask(String id) {
    tasks.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  // ---------------- Habits ----------------

  void addHabit(Habit h) {
    habits.add(h);
    _persist();
    notifyListeners();
  }

  void toggleHabitToday(String id) {
    final h = habits.firstWhere((e) => e.id == id);
    final today = DateTime.now();
    final key = _isoDate(today);
    if (h.completedDates.contains(key)) {
      h.completedDates.remove(key);
    } else {
      h.completedDates.add(key);
      _markActiveToday();
    }
    _persist();
    notifyListeners();
  }

  void deleteHabit(String id) {
    habits.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  // ---------------- Goals ----------------

  Goal? goalById(String id) {
    for (final g in goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  void addGoal(Goal g) {
    goals.add(g);
    _persist();
    notifyListeners();
  }

  void addSubGoal(String goalId, String title) {
    final g = goals.firstWhere((e) => e.id == goalId);
    g.subGoals.add(SubGoal(id: newId(), title: title));
    _persist();
    notifyListeners();
  }

  void toggleSubGoal(String goalId, String subGoalId) {
    final g = goals.firstWhere((e) => e.id == goalId);
    final sg = g.subGoals.firstWhere((e) => e.id == subGoalId);
    sg.done = !sg.done;
    if (sg.done) _markActiveToday();
    _persist();
    notifyListeners();
  }

  void deleteGoal(String id) {
    goals.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  // ---------------- Activities ----------------

  void addActivity(Activity a) {
    activities.add(a);
    _persist();
    notifyListeners();
  }

  void logActivityMinutes(String id, int minutes) {
    final a = activities.firstWhere((e) => e.id == id);
    a.sessions.add(ActivitySession(date: DateTime.now(), minutes: minutes));
    _markActiveToday();
    _persist();
    notifyListeners();
  }

  void deleteActivity(String id) {
    activities.removeWhere((e) => e.id == id);
    _persist();
    notifyListeners();
  }

  // ---------------- Demo seed (first launch only) ----------------

  void _seedDemoData() {
    final now = DateTime.now();
    tasks = [
      Task(id: newId(), title: 'Finish Flutter UI', priority: Priority.high, due: DateTime(now.year, now.month, now.day, 14, 0)),
      Task(id: newId(), title: 'Study Data Structures', priority: Priority.high, due: DateTime(now.year, now.month, now.day, 11, 0)),
      Task(id: newId(), title: 'Read 20 pages', priority: Priority.medium, due: DateTime(now.year, now.month, now.day, 12, 0)),
      Task(id: newId(), title: 'Drink water', isRecurring: true, recurrenceLabel: 'Every 2 hours', due: now),
      Task(id: newId(), title: 'Take vitamins', isRecurring: true, recurrenceLabel: 'Every day, 8:00 AM', due: now),
    ];
    habits = [
      Habit(id: newId(), name: 'Meditate', icon: Icons.self_improvement, frequency: Frequency(type: FrequencyType.daily)),
      Habit(id: newId(), name: 'Drink Water', icon: Icons.local_drink, frequency: Frequency(type: FrequencyType.daily, timesPerDay: 4)),
      Habit(id: newId(), name: 'Read', icon: Icons.menu_book, frequency: Frequency(type: FrequencyType.weekly, daysPerWeek: 5)),
      Habit(id: newId(), name: 'Workout', icon: Icons.fitness_center, frequency: Frequency(type: FrequencyType.weekly, daysPerWeek: 4)),
    ];
    goals = [
      Goal(
        id: newId(),
        title: 'Build a complete Flutter app',
        description: 'Build a full Flutter application and publish it on the Play Store.',
        due: DateTime(now.year, now.month + 1, now.day),
        icon: Icons.emoji_events,
        subGoals: [
          SubGoal(id: newId(), title: 'UI Design', done: true),
          SubGoal(id: newId(), title: 'Authentication', done: true),
          SubGoal(id: newId(), title: 'Database'),
          SubGoal(id: newId(), title: 'State Management'),
          SubGoal(id: newId(), title: 'Deployment'),
        ],
      ),
    ];
    activities = [
      Activity(
        id: newId(),
        name: 'Reading',
        icon: Icons.menu_book,
        frequency: Frequency(type: FrequencyType.daily),
        weeklyGoalMinutes: 300,
        sessions: [ActivitySession(date: now.subtract(const Duration(days: 1)), minutes: 90), ActivitySession(date: now, minutes: 30)],
      ),
      Activity(
        id: newId(),
        name: 'Coding',
        icon: Icons.code,
        frequency: Frequency(type: FrequencyType.daily),
        weeklyGoalMinutes: 360,
        sessions: [ActivitySession(date: now, minutes: 120)],
      ),
    ];
    activeDays = {_isoDate(now)};
  }
}