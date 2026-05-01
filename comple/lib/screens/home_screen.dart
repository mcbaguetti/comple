import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';
import '../services/storage_service.dart';
import '../widgets/add_birthday_dialog.dart';
import '../main.dart';
import '../services/error_service.dart';
// import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;

  const HomeScreen({Key? key, required this.storageService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ValueNotifier<List<Birthday>> _upcomingBirthdaysNotifier;
  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Birthday> _allBirthdays = [];
  double _calendarHeight = 350.0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _upcomingBirthdaysNotifier = ValueNotifier([]);
    _loadBirthdays();
  }

  void _loadBirthdays() {
    try {
      setState(() {
        _allBirthdays = widget.storageService.getBirthdays();
        _upcomingBirthdaysNotifier.value = _getUpcomingBirthdays();
      });
    } catch (e, st) {
      logError(e, st);
    }
  }

  List<Birthday> _getUpcomingBirthdays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<Map<String, dynamic>> upcoming = [];
    
    for (var b in _allBirthdays) {
      DateTime nextDate = DateTime(today.year, b.date.month, b.date.day);
      if (nextDate.isBefore(today)) {
        nextDate = DateTime(today.year + 1, b.date.month, b.date.day);
      }
      upcoming.add({
        'birthday': b,
        'daysUntil': nextDate.difference(today).inDays,
      });
    }
    
    upcoming.sort((a, b) => (a['daysUntil'] as int).compareTo(b['daysUntil'] as int));
    
    return upcoming.take(5).map((e) => e['birthday'] as Birthday).toList();
  }

  List<Birthday> _getBirthdaysForDay(DateTime day) {
    // Birthdays happen every year, so we ignore the year of the birth date
    // when checking against the calendar 'day'.
    return _allBirthdays.where((b) {
      return b.date.month == day.month && b.date.day == day.day;
    }).toList();
  }

  @override
  void dispose() {
    _upcomingBirthdaysNotifier.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
        if (format == CalendarFormat.month) {
          _calendarHeight = 350.0;
        } else if (format == CalendarFormat.twoWeeks) {
          _calendarHeight = 220.0;
        } else if (format == CalendarFormat.week) {
          _calendarHeight = 140.0;
        }
      });
    }
  }

  void _showAddDialog() async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AddBirthdayDialog(
          storageService: widget.storageService,
          initialDate: _selectedDay,
        ),
      );
      if (result == true) {
        _loadBirthdays();
      }
    } catch (e, st) {
      logError(e, st);
    }
  }

  void _deleteBirthday(Birthday birthday) async {
    try {
      await widget.storageService.removeBirthday(birthday.id);
      _loadBirthdays();
    } catch (e, st) {
      logError(e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<CalendarFormat>(
          icon: const Icon(Icons.date_range, size: 20),
          initialValue: _calendarFormat,
          tooltip: 'Select view format',
          onSelected: _onFormatChanged,
          itemBuilder: (context) => [
            const PopupMenuItem(value: CalendarFormat.month, child: Center(child: Text('Month'))),
            const PopupMenuItem(value: CalendarFormat.twoWeeks, child: Center(child: Text('2 Weeks'))),
            const PopupMenuItem(value: CalendarFormat.week, child: Center(child: Text('Week'))),
          ],
        ),
        title: const Text('_comple_', style: TextStyle(fontSize: 12.0, fontFamily: 'monospace')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.light ? Icons.dark_mode : Icons.light_mode, size: 20),
            onPressed: () {
              setState(() {
                if (Theme.of(context).brightness == Brightness.light) {
                  themeNotifier.value = ThemeMode.dark;
                } else {
                  themeNotifier.value = ThemeMode.light;
                }
              });
            },
          ),
            // IconButton(
            //   icon: const Icon(Icons.bug_report, size: 20),
            //   tooltip: 'Send test notification',
            //   onPressed: () async {
            //     try {
            //       // await NotificationService().scheduleTestNotification(seconds: 5);
            //     } catch (e, st) {
            //       logError(e, st);
            //     }
            //   },
            // ),
          const SizedBox(width: 8.0),
        ],
        flexibleSpace: Container(
          color: Theme.of(context).colorScheme.surface,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const Divider(height: 1.0, thickness: 1.0),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: _calendarHeight,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: TableCalendar<Birthday>(
                firstDay: DateTime(1900, 1, 1),
                lastDay: DateTime(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                onFormatChanged: _onFormatChanged,
                eventLoader: _getBirthdaysForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  headerPadding: EdgeInsets.only(top: 2.0, bottom: 12.0),
                  headerMargin: EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  todayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _calendarHeight += details.delta.dy;
                if (_calendarHeight < 130) _calendarHeight = 130;
                if (_calendarHeight > 360) _calendarHeight = 360;
              });
            },
            onVerticalDragEnd: (details) {
              setState(() {
                // Determine closest snap point and assign format explicitly
                if (_calendarHeight > 315) {
                  _calendarHeight = 350.0;
                  _calendarFormat = CalendarFormat.month;
                } else if (_calendarHeight > 250) {
                  _calendarHeight = 280.0; // 3 weeks height
                  _calendarFormat = CalendarFormat.month; 
                } else if (_calendarHeight > 180) {
                  _calendarHeight = 220.0;
                  _calendarFormat = CalendarFormat.twoWeeks;
                } else {
                  _calendarHeight = 140.0;
                  _calendarFormat = CalendarFormat.week;
                }
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  const Divider(height: 16.0, thickness: 1.0),
                  Container(
                    width: 25,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text('upcoming birthdays', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.2)),
                    ),
                  ),
                  const Divider(height: 8.0, thickness: 1.0),
                ],
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Birthday>>(
              valueListenable: _upcomingBirthdaysNotifier,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(child: Text('No upcoming birthdays.'));
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final birthday = value[index];
                    return ListTile(
                      title: Text(birthday.name),
                      subtitle: Text(birthday.date.year == 0 
                          ? DateFormat.MMMd().format(birthday.date)
                          : '${DateFormat.MMMd().format(birthday.date)} (Turning ${DateTime.now().year - birthday.date.year})'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteBirthday(birthday),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
