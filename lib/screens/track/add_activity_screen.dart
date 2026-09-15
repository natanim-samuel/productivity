import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

class AddActivityScreen extends StatefulWidget {
  /// Reused for both "Add Habit" and "Add Activity" — a habit IS a recurring
  /// activity, so they share the same frequency-picker form. [isHabit]
  /// decides which list in AppState the result is saved to.
  final bool isHabit;
  const AddActivityScreen({super.key, this.isHabit = false});
  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _nameController = TextEditingController();
  final _goalMinutesController = TextEditingController(text: '180');
  IconData _selectedIcon = Icons.menu_book;
  final _freq = Frequency();

  static const _icons = [
    Icons.menu_book,
    Icons.code,
    Icons.fitness_center,
    Icons.music_note,
    Icons.brush,
    Icons.self_improvement,
    Icons.local_drink,
  ];

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void dispose() {
    _nameController.dispose();
    _goalMinutesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;
    final state = context.read<AppState>();
    if (widget.isHabit) {
      state.addHabit(Habit(id: newId(), name: _nameController.text.trim(), icon: _selectedIcon, frequency: _freq));
    } else {
      final goalMinutes = int.tryParse(_goalMinutesController.text.trim()) ?? 180;
      state.addActivity(Activity(id: newId(), name: _nameController.text.trim(), icon: _selectedIcon, frequency: _freq, weeklyGoalMinutes: goalMinutes));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final kindLabel = widget.isHabit ? 'Habit' : 'Activity';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Text('Add $kindLabel', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            _textField(_nameController, 'e.g. Reading'),

            const SizedBox(height: 20),
            const Text('Icon', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons.map((icon) {
                final selected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : AppColors.surface,
                      border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                    ),
                    child: Icon(icon, color: selected ? Colors.white : AppColors.textSecondary, size: 20),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text('How often?', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            _frequencyTypeSwitch(),

            const SizedBox(height: 20),
            _frequencyDetail(),

            if (!widget.isHabit) ...[
              const SizedBox(height: 24),
              const Text('Weekly time goal (minutes)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              _textField(_goalMinutesController, 'e.g. 180', keyboardType: TextInputType.number),
            ],

            const SizedBox(height: 28),
            AppCard(
              child: Row(
                children: [
                  Icon(_selectedIcon, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isEmpty ? '$kindLabel name' : _nameController.text,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        Text(_freq.summary, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save $kindLabel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _frequencyTypeSwitch() {
    final labels = {FrequencyType.daily: 'Daily', FrequencyType.weekly: 'Weekly', FrequencyType.monthly: 'Monthly'};
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: FrequencyType.values.map((type) {
          final selected = type == _freq.type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _freq.type = type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(labels[type]!, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 13)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _frequencyDetail() {
    switch (_freq.type) {
      case FrequencyType.daily:
        return AppCard(
          child: _stepperRow(
            label: 'Times per day',
            value: _freq.timesPerDay,
            min: 1,
            max: 10,
            onChanged: (v) => setState(() => _freq.timesPerDay = v),
          ),
        );
      case FrequencyType.weekly:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stepperRow(
                label: 'Days per week',
                value: _freq.daysPerWeek,
                min: 1,
                max: 7,
                onChanged: (v) => setState(() => _freq.daysPerWeek = v),
              ),
              const SizedBox(height: 16),
              const Text('Which days? (optional)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final selected = _freq.weekdays.contains(i);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _freq.weekdays.remove(i);
                      } else {
                        _freq.weekdays.add(i);
                      }
                    }),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppColors.primary : AppColors.surfaceAlt,
                      ),
                      alignment: Alignment.center,
                      child: Text(_weekdayLabels[i], style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12)),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      case FrequencyType.monthly:
        return AppCard(
          child: _stepperRow(
            label: 'Times per month',
            value: _freq.timesPerMonth,
            min: 1,
            max: 31,
            onChanged: (v) => setState(() => _freq.timesPerMonth = v),
          ),
        );
    }
  }

  Widget _stepperRow({required String label, required int value, required int min, required int max, required ValueChanged<int> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
        Row(
          children: [
            _stepperButton(Icons.remove, () {
              if (value > min) onChanged(value - 1);
            }),
            SizedBox(
              width: 32,
              child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ),
            _stepperButton(Icons.add, () {
              if (value < max) onChanged(value + 1);
            }),
          ],
        ),
      ],
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.textPrimary, size: 16),
      ),
    );
  }
}