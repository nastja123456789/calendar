import 'dart:async';

import 'package:calendar/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Map<DateTime, List<Event>> selectedEvents;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  TextEditingController _eventController = TextEditingController();
  String _time;
  String _day;

  @override
  void initState() {
    selectedEvents = {};
    _time = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (t) => _getTime());
    _day = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (t) => _getDay());
    super.initState();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  String dropdownValue = 'Встреча';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Align(
              alignment: Alignment.lerp(Alignment.bottomLeft, Alignment.bottomCenter,0.1),
              child: Text(
                _time,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 42,
                ),
              ),
            ),
          ),
          Center(
            child: Align(
              alignment: Alignment.lerp(Alignment.bottomLeft, Alignment.bottomCenter,0.1),
              child: Text(
                _day,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          Container(
            child: TableCalendar(
              locale: 'ru_RU',
              startingDayOfWeek: StartingDayOfWeek.monday,
              focusedDay: selectedDay,
              firstDay: DateTime(1990),
              lastDay: DateTime(2050),
              calendarFormat: format,
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: (context, date, event) {
                  return Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (event as Event).status == 'Встреча' ? Colors.blueAccent : (event as Event).status == 'Выходной' ? Colors.lightBlue : Colors.red),
                    width: 5.0,
                    height: 5.0,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  );
                },
              ),
              daysOfWeekVisible: true,
              daysOfWeekStyle: DaysOfWeekStyle(
                decoration: BoxDecoration(
                    color: Colors.black26
                ),
              ),

              //Day Changed
              onDaySelected: (DateTime selectDay, DateTime focusDay) {
                setState(() {
                  selectedDay = selectDay;
                  focusedDay = focusDay;
                });
                print(focusedDay);
              },
              selectedDayPredicate: (DateTime date) {
                return isSameDay(selectedDay, date);
              },

              eventLoader: _getEventsfromDay,

              //To style the Calendar
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                defaultDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                decoration: BoxDecoration(
                  color: Colors.black38
                )
              ),
            ),
            color: Colors.black12,
            margin: const EdgeInsets.all(35),
          ),
          ..._getEventsfromDay(selectedDay).map(
            (Event event) => ListTile(
              title: Text(
                event.title,
              ),
              textColor: (event as Event).status == 'Встреча' ? Colors.blueAccent : (event as Event).status == 'Выходной' ? Colors.lightBlue : Colors.red,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,

          builder: (BuildContext context) {
            int selectedRadio = 0;
            return AlertDialog(
              title: Text("Добавить событие"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    if (_eventController.text.isEmpty) {

                    } else {
                      if (selectedEvents[selectedDay] != null) {
                        selectedEvents[selectedDay].add(
                          Event(title: _eventController.text, status: dropdownValue),
                        );
                      } else {
                        selectedEvents[selectedDay] = [
                          Event(title: _eventController.text, status: dropdownValue)
                        ];
                      }

                    }
                    Navigator.pop(context);
                    _eventController.clear();
                    setState((){

                    });
                    return;
                  },
                ),
              ],
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _eventController,
                        ),

                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                          },
                          items: <String>['Встреча', 'Выходной', 'День Рождения']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: value == 'Встреча' ? const TextStyle(color: Colors.blueAccent) : value == 'Выходной' ? const TextStyle(color: Colors.lightBlue) : const TextStyle(color: Colors.red)),
                            );
                          }).toList(),
                        )]
                  );
                },
              ),
            );
          },
        ),
        label: Text("Добавить событие"),
        icon: Icon(Icons.add),
      ),

    );
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formatted = _formatDateTime(now);
    setState(() {
      _time = formatted;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.Hm('ru-RU').format(dateTime);
  }

  void _getDay() {
    final DateTime now = DateTime.now();
    final String formatted = _formatDate(now);
    setState(() {
      _day = formatted;
    });
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }
}

