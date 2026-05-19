import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

/// Shows the reschedule bottom sheet and calls [onConfirm] with the selected ISO date.
/// [initialDate] is the current due date of the node — the calendar opens on that day.

/// Used ClaudeAI 
Future<void> showRescheduleWidget(
  BuildContext context, {
  required Future<bool> Function(String dateIso) onConfirm,
  DateTime? initialDate,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
        child: _RescheduleWidget(onConfirm: onConfirm, initialDate: initialDate),
    ),
  );
}

class _RescheduleWidget extends StatefulWidget {
  final Future<bool> Function(String dateIso) onConfirm;
  final DateTime? initialDate;
  const _RescheduleWidget({required this.onConfirm, this.initialDate});

  @override
  State<_RescheduleWidget> createState() => _RescheduleWidgetState();
}

class _RescheduleWidgetState extends State<_RescheduleWidget> {
  final DateTime _today = DateTime.now();
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late TextEditingController _offsetController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate;
    final today = DateTime(_today.year, _today.month, _today.day);
    // Open on the node's due date, but fall back to today if it's in the past
    final startDay = (initial != null && !initial.isBefore(today)) ? initial : today;
    _focusedDay = startDay;
    _selectedDay = startDay;
    final offset = DateTime(startDay.year, startDay.month, startDay.day)
        .difference(today)
        .inDays;
    _offsetController = TextEditingController(text: offset.toString());
  }

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day) {
    if (day.isBefore(DateTime(_today.year, _today.month, _today.day))) return;
    final offset = DateTime(day.year, day.month, day.day)
    .difference(DateTime(_today.year, _today.month, _today.day))
    .inDays;
    _applyOffset(offset);
  }

  void _applyOffset(int offset) {
    final newDay = DateTime(_today.year, _today.month, _today.day)
    .add(Duration(days: offset));
    setState(() {
        _selectedDay = newDay;
        _focusedDay = newDay;
        _offsetController.text = offset.toString();
    });
  }

  void _onOffsetChanged(String value) {
    final offset = int.tryParse(value);
    if (offset == null || offset < 0) return;
    _applyOffset(offset);
  }

  String get _selectedIso {
    return '${_selectedDay.year.toString().padLeft(4, '0')}'
        '-${_selectedDay.month.toString().padLeft(2, '0')}'
        '-${_selectedDay.day.toString().padLeft(2, '0')}';
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final ok = await widget.onConfirm(_selectedIso);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    double dragAccumulator = 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Reschedule',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // Offset field
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Zone de scroll vertical
                    
                    GestureDetector(
                      onVerticalDragUpdate: (details) {
                        dragAccumulator += -details.primaryDelta!;
                        final steps = dragAccumulator ~/ 6; // seuil en pixels par step
                        if (steps == 0) return;
                        dragAccumulator -= steps * 6;
                        final current = int.tryParse(_offsetController.text) ?? 0;
                        final next = (current + steps).clamp(0, 99999);
                        _applyOffset(next);
                      },
                      onVerticalDragEnd: (_) => dragAccumulator = 0,
                      child: Container(
                        width: 48,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                        ),
                        child: Icon(Icons.unfold_more, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ),
                    // Champ texte précis
                    SizedBox(
                      width: 64,
                      child: TextField(
                        controller: _offsetController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          suffixText: 'd',
                          suffixStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 13),
                          border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: cs.primary, width: 1.5),
                          ),
                        ),
                        onChanged: _onOffsetChanged,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const Divider(height: 1),

          // Calendar
          TableCalendar(
            sixWeekMonthsEnforced: true,
            rowHeight: 48,
            firstDay: _today,
            lastDay: DateTime(_today.year + 100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronPadding: const EdgeInsets.all(14),
              rightChevronPadding: const EdgeInsets.all(14),
              titleTextStyle: theme.textTheme.titleSmall!
                  .copyWith(fontWeight: FontWeight.w500),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: cs.onSurface, size: 20),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: cs.onSurface, size: 20),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: theme.textTheme.labelSmall!
                  .copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
              weekendStyle: theme.textTheme.labelSmall!
                  .copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              disabledTextStyle: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.2), fontSize: 13),
              todayDecoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
              selectedDecoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                  color: cs.onPrimary, fontWeight: FontWeight.w600),
              defaultTextStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            ),
            enabledDayPredicate: (day) {
              final d = DateTime(day.year, day.month, day.day);
              final t = DateTime(_today.year, _today.month, _today.day);
              return !d.isBefore(t);
            },
            onDaySelected: (selected, focused) => _onDaySelected(selected),
            onPageChanged: (focused) =>
                setState(() => _focusedDay = focused),
          ),

          const Divider(height: 1),

          // Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _confirm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : Text(
                        'Schedule for $_selectedIso',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
