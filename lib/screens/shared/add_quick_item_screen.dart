import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/misc_widgets.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';

enum QuickItemKind { task, goal }

class AddQuickItemScreen extends StatefulWidget {
  final QuickItemKind kind;
  const AddQuickItemScreen({super.key, required this.kind});

  @override
  State<AddQuickItemScreen> createState() => _AddQuickItemScreenState();
}

class _AddQuickItemScreenState extends State<AddQuickItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Priority _priority = Priority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  bool get _isTask => widget.kind == QuickItemKind.task;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime? get _combinedDue {
    if (_dueDate == null) return null;
    final t = _dueTime ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day, t.hour, t.minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _dueTime ?? TimeOfDay.now());
    if (picked != null) setState(() => _dueTime = picked);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final state = context.read<AppState>();
    if (_isTask) {
      state.addTask(Task(
        id: newId(),
        title: _titleController.text.trim(),
        due: _combinedDue,
        priority: _priority,
      ));
    } else {
      state.addGoal(Goal(
        id: newId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        due: _dueDate,
        icon: Icons.flag,
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final label = _isTask ? 'Task' : 'Goal';
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
                Text('Add $label', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),
            Text(_isTask ? 'Title' : 'Goal name', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            _textField(_titleController, _isTask ? 'e.g. Finish Flutter UI' : 'e.g. Build a complete Flutter app'),
            if (!_isTask) ...[
              const SizedBox(height: 20),
              const Text('Description (optional)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              _textField(_descriptionController, 'What does finishing this look like?'),
            ],
            const SizedBox(height: 20),
            Text(_isTask ? 'Due' : 'Due date', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: _pickerBox(_dueDate == null ? 'Pick a date' : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'),
                  ),
                ),
                if (_isTask) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: _pickerBox(_dueTime == null ? 'Pick a time' : _dueTime!.format(context)),
                    ),
                  ),
                ],
              ],
            ),
            if (_isTask) ...[
              const SizedBox(height: 20),
              const Text('Priority', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: Priority.values.map((p) {
                  final selected = p == _priority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                        ),
                        child: Text(
                          p == Priority.high ? 'High' : p == Priority.medium ? 'Medium' : 'Low',
                          style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Save $label'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
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
}