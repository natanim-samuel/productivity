import 'package:flutter/material.dart';

enum Priority { high, medium, low }

Priority? priorityFromString(String? s) {
  if (s == null) return null;
  return Priority.values.firstWhere((p) => p.name == s, orElse: () => Priority.medium);
}

enum FrequencyType { daily, weekly, monthly }

/// Shared "how often" model used by both Habits and Activities.
class Frequency {
  FrequencyType type;
  int timesPerDay;
  int daysPerWeek;
  Set<int> weekdays; // 0=Mon .. 6=Sun
  int timesPerMonth;

  Frequency({
    this.type = FrequencyType.daily,
    this.timesPerDay = 1,
    this.daysPerWeek = 3,
    Set<int>? weekdays,
    this.timesPerMonth = 4,
  }) : weekdays = weekdays ?? {0, 2, 4};

  String get summary {
    switch (type) {
      case FrequencyType.daily:
        return timesPerDay == 1 ? 'Once a day' : '$timesPerDay times a day';
      case FrequencyType.weekly:
        return '$daysPerWeek day${daysPerWeek == 1 ? '' : 's'} a week';
      case FrequencyType.monthly:
        return '$timesPerMonth time${timesPerMonth == 1 ? '' : 's'} a month';
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'timesPerDay': timesPerDay,
    'daysPerWeek': daysPerWeek,
    'weekdays': weekdays.toList(),
    'timesPerMonth': timesPerMonth,
  };

  factory Frequency.fromJson(Map<String, dynamic> j) => Frequency(
    type: FrequencyType.values.firstWhere((t) => t.name == j['type'], orElse: () => FrequencyType.daily),
    timesPerDay: j['timesPerDay'] ?? 1,
    daysPerWeek: j['daysPerWeek'] ?? 3,
    weekdays: (j['weekdays'] as List?)?.map((e) => e as int).toSet() ?? {0, 2, 4},
    timesPerMonth: j['timesPerMonth'] ?? 4,
  );
}

String _dateKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class Task {
  String id;
  String title;
  DateTime? due;
  Priority? priority;
  bool isRecurring;
  String? recurrenceLabel;
  bool completed;

  Task({
    required this.id,
    required this.title,
    this.due,
    this.priority,
    this.isRecurring = false,
    this.recurrenceLabel,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'due': due?.toIso8601String(),
    'priority': priority?.name,
    'isRecurring': isRecurring,
    'recurrenceLabel': recurrenceLabel,
    'completed': completed,
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'],
    title: j['title'],
    due: j['due'] != null ? DateTime.parse(j['due']) : null,
    priority: priorityFromString(j['priority']),
    isRecurring: j['isRecurring'] ?? false,
    recurrenceLabel: j['recurrenceLabel'],
    completed: j['completed'] ?? false,
  );
}

class Habit {
  String id;
  String name;
  IconData icon;
  Frequency frequency;
  Set<String> completedDates; // 'yyyy-MM-dd'

  Habit({required this.id, required this.name, required this.icon, required this.frequency, Set<String>? completedDates})
      : completedDates = completedDates ?? {};

  bool isDoneOn(DateTime d) => completedDates.contains(_dateKey(d));
  bool get isDoneToday => isDoneOn(DateTime.now());

  /// Consecutive days ending today (or yesterday, so missing today doesn't
  /// zero out the streak until the day actually passes) that are marked done.
  int get streak {
    int count = 0;
    DateTime cursor = DateTime.now();
    if (!isDoneOn(cursor)) cursor = cursor.subtract(const Duration(days: 1));
    while (isDoneOn(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  /// Done/missed/future state for the 7 days Mon..Sun of the current week.
  List<String> weekStates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      if (day.isAfter(DateTime(now.year, now.month, now.day))) return 'future';
      return isDoneOn(day) ? 'done' : 'missed';
    });
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCodePoint': icon.codePoint,
    'frequency': frequency.toJson(),
    'completedDates': completedDates.toList(),
  };

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
    id: j['id'],
    name: j['name'],
    icon: IconData(j['iconCodePoint'], fontFamily: 'MaterialIcons'),
    frequency: Frequency.fromJson(j['frequency']),
    completedDates: (j['completedDates'] as List?)?.map((e) => e as String).toSet() ?? {},
  );
}

class SubGoal {
  String id;
  String title;
  bool done;
  SubGoal({required this.id, required this.title, this.done = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'done': done};
  factory SubGoal.fromJson(Map<String, dynamic> j) => SubGoal(id: j['id'], title: j['title'], done: j['done'] ?? false);
}

class Goal {
  String id;
  String title;
  String description;
  DateTime? due;
  IconData icon;
  List<SubGoal> subGoals;

  Goal({required this.id, required this.title, this.description = '', this.due, required this.icon, List<SubGoal>? subGoals})
      : subGoals = subGoals ?? [];

  double get progress {
    if (subGoals.isEmpty) return 0;
    return subGoals.where((s) => s.done).length / subGoals.length;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'due': due?.toIso8601String(),
    'iconCodePoint': icon.codePoint,
    'subGoals': subGoals.map((s) => s.toJson()).toList(),
  };

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
    id: j['id'],
    title: j['title'],
    description: j['description'] ?? '',
    due: j['due'] != null ? DateTime.parse(j['due']) : null,
    icon: IconData(j['iconCodePoint'], fontFamily: 'MaterialIcons'),
    subGoals: (j['subGoals'] as List? ?? []).map((e) => SubGoal.fromJson(e)).toList(),
  );
}

class ActivitySession {
  DateTime date;
  int minutes;
  ActivitySession({required this.date, required this.minutes});

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'minutes': minutes};
  factory ActivitySession.fromJson(Map<String, dynamic> j) => ActivitySession(date: DateTime.parse(j['date']), minutes: j['minutes']);
}

class Activity {
  String id;
  String name;
  IconData icon;
  Frequency frequency;
  int weeklyGoalMinutes;
  List<ActivitySession> sessions;

  Activity({
    required this.id,
    required this.name,
    required this.icon,
    required this.frequency,
    this.weeklyGoalMinutes = 180,
    List<ActivitySession>? sessions,
  }) : sessions = sessions ?? [];

  int get minutesThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return sessions.where((s) => s.date.isAfter(weekAgo)).fold(0, (sum, s) => sum + s.minutes);
  }

  double get weeklyProgress => weeklyGoalMinutes == 0 ? 0 : (minutesThisWeek / weeklyGoalMinutes).clamp(0, 1);

  String get minutesThisWeekLabel {
    final m = minutesThisWeek;
    if (m < 60) return '${m}m this week';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h this week' : '${h}h ${rem}m this week';
  }

  String get goalLabel {
    if (weeklyGoalMinutes < 60) return 'Goal: ${weeklyGoalMinutes}m';
    final h = weeklyGoalMinutes ~/ 60;
    final rem = weeklyGoalMinutes % 60;
    return rem == 0 ? 'Goal: ${h}h' : 'Goal: ${h}h ${rem}m';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCodePoint': icon.codePoint,
    'frequency': frequency.toJson(),
    'weeklyGoalMinutes': weeklyGoalMinutes,
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
    id: j['id'],
    name: j['name'],
    icon: IconData(j['iconCodePoint'], fontFamily: 'MaterialIcons'),
    frequency: Frequency.fromJson(j['frequency']),
    weeklyGoalMinutes: j['weeklyGoalMinutes'] ?? 180,
    sessions: (j['sessions'] as List? ?? []).map((e) => ActivitySession.fromJson(e)).toList(),
  );
}

/// Simple id generator — good enough without pulling in a uuid package.
String newId() => DateTime.now().microsecondsSinceEpoch.toString();