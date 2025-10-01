import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '../customize_appbar_screen.dart';
import '/widgets/customize_navbar.dart';
import 'appointment_result.dart';

class CalendarAppointmentScreen extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String doctorClinic;
  final String doctorImage;
  final String patientName; // from logged-in user

  const CalendarAppointmentScreen({
    super.key,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorClinic,
    required this.doctorImage,
    required this.patientName,
  });

  @override
  State<CalendarAppointmentScreen> createState() =>
      _CalendarAppointmentScreenState();
}

class _CalendarAppointmentScreenState
    extends State<CalendarAppointmentScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDay = DateTime.now();
  String? _selectedTime;

  final List<String> timeSlots = [
    "09:00 AM",
    "09:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "12:30 PM",
    "01:00 PM",
    "01:30 PM",
    "02:00 PM",
    "02:30 PM",
    "03:00 PM",
    "03:30 PM",
    "04:00 PM",
  ];

  Future<void> _bookAppointment() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time")),
      );
      return;
    }

    try {
      // Combine selected day and time
      final timeParts = _selectedTime!.split(RegExp(r'[: ]')); // ["09","00","AM"]
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      if (timeParts[2] == "PM" && hour != 12) hour += 12;
      if (timeParts[2] == "AM" && hour == 12) hour = 0;

      final appointmentDateTime = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
        hour,
        minute,
      );

      // Save appointment to Firestore
      await FirebaseFirestore.instance.collection("appointments").add({
        "doctorName": widget.doctorName,
        "doctorSpecialty": widget.doctorSpecialty,
        "doctorClinic": widget.doctorClinic,
        "doctorImage": widget.doctorImage,
        "patientName": widget.patientName,
        "date": Timestamp.fromDate(appointmentDateTime), // ✅ Timestamp
        "time": _selectedTime,
        "createdAt": Timestamp.now(),
      });

      // Navigate to result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentResultScreen(
            doctorName: widget.doctorName,
            patientName: widget.patientName,
            date: appointmentDateTime,
            time: _selectedTime!,
            doctorImage: widget.doctorImage,
            doctorSpecialty: widget.doctorSpecialty,
            doctorClinic: widget.doctorClinic,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error booking: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizeAppBarScreen(
        onNotificationsTap: () {
          debugPrint("Notifications tapped");
        },
        onProfileTap: () {
          debugPrint("Profile tapped");
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Book Appointment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Doctor Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.doctorImage,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(widget.doctorName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "${widget.doctorSpecialty}\n${widget.doctorClinic}"),
              ),
            ),

            const SizedBox(height: 16),

            // 📅 Calendar
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TableCalendar(
                focusedDay: _selectedDay,
                firstDay: DateTime.now(),
                lastDay: DateTime(2100),
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(fontSize: 13),
                  weekendTextStyle: TextStyle(fontSize: 13),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 12),
                  weekendStyle: TextStyle(fontSize: 12),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Select Hour",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // ⏰ Time Slots
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final time = timeSlots[index];
                final isSelected = _selectedTime == time;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                          : [],
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomizeNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
