import 'package:flutter/material.dart';
import 'package:mycelium/data/models/day_review_overview.dart';
import 'package:table_calendar/table_calendar.dart';

// ClaudeAI
class RepsCalendar extends StatefulWidget {
  final Map<DateTime, DayReviewOverview> reps;

  const RepsCalendar({super.key, required this.reps});

  @override
  State<RepsCalendar> createState() => _RepsCalendarState();
}

class _RepsCalendarState extends State<RepsCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  int _total(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final data = widget.reps[key];
    return data != null ? data.dueSpores + data.dueFragments : 0;
  }

  int get _maxTotal {
    if (widget.reps.isEmpty) return 1;
    return widget.reps.values
        .map((d) => d.dueSpores + d.dueFragments)
        .reduce((a, b) => a > b ? a : b);
  }

  Color _heatColor(int total, ColorScheme cs) {
    if (total == 0) return Colors.transparent;
    final t = (total / _maxTotal).clamp(0.0, 1.0);
    return cs.primary.withValues(alpha: 0.15 + t * 0.75);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selected = _selectedDay;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCalendar(
          sixWeekMonthsEnforced: true,
          rowHeight: 52,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronPadding: const EdgeInsets.all(16),
            rightChevronPadding: const EdgeInsets.all(16),
            titleTextStyle: theme.textTheme.titleSmall!
                .copyWith(fontWeight: FontWeight.w500),
            leftChevronIcon: Icon(Icons.chevron_left, color: cs.onSurface),
            rightChevronIcon: Icon(Icons.chevron_right, color: cs.onSurface),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.labelSmall!
                .copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
            weekendStyle: theme.textTheme.labelSmall!
                .copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            todayDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              border: Border.all(color: cs.primary, width: 1.5),
              shape: BoxShape.circle,
            ),
            selectedTextStyle:
                TextStyle(color: cs.primary, fontWeight: FontWeight.w500),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) =>
                _dayCell(day, cs, theme),
            outsideBuilder: (context, day, focusedDay) => const SizedBox(),
            todayBuilder: (context, day, focusedDay) =>
                _dayCell(day, cs, theme, isToday: true),
            selectedBuilder: (context, day, focusedDay) =>
                _dayCell(day, cs, theme, isSelected: true),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() => _focusedDay = focusedDay);
          },
        ),
        const Divider(height: 1),
        _DetailPanel(
          selectedDay: selected,
          data: selected != null
              ? widget.reps[DateTime(selected.year, selected.month, selected.day)]
              : null,
        ),
      ],
    );
  }

  Widget _dayCell(
    DateTime day,
    ColorScheme cs,
    ThemeData theme, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final total = _total(day);
    final heat = _heatColor(total, cs);

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isToday
            ? cs.primary
            : isSelected
                ? Colors.transparent
                : heat,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: cs.primary, width: 1.5)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: theme.textTheme.labelSmall!.copyWith(
                color: isToday
                    ? cs.onPrimary
                    : isSelected
                        ? cs.primary
                        : heat != Colors.transparent && heat.computeLuminance() < 0.35
                            ? Colors.white
                            : cs.onSurface,
              ),
            ),
            if (total > 0)
              Text(
                '$total',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? cs.primary
                      : heat.computeLuminance() > 0.35
                          ? Colors.black87
                          : Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final DateTime? selectedDay;
  final DayReviewOverview? data;

  const _DetailPanel({this.selectedDay, this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (selectedDay == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Tap a day to see details',
          style: theme.textTheme.bodySmall!
              .copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
          textAlign: TextAlign.center,
        ),
      );
    }

    final d = data;
    final dateStr =
        '${selectedDay!.day} ${_monthShort(selectedDay!.month)} ${selectedDay!.year}';

    final spores = d?.dueSpores ?? 0;
    final fragments = d?.dueFragments ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateStr,
            style: theme.textTheme.labelMedium!
                .copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _Row('Fragments', fragments, theme),
          _Row('Spores', spores, theme),
          const Divider(height: 16),
          _Row('Total', spores + fragments, theme, bold: true),
        ],
      ),
    );
  }

  Widget _Row(String label, int value, ThemeData theme,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall!
                  .copyWith(fontWeight: bold ? FontWeight.w500 : FontWeight.w400),
            ),
          ),
          Text(
            '$value',
            style: theme.textTheme.bodySmall!
                .copyWith(fontWeight: bold ? FontWeight.w500 : FontWeight.w400),
          ),
        ],
      ),
    );
  }

  String _monthShort(int m) => const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m];
}

