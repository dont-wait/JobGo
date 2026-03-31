import 'package:flutter/material.dart';
import 'package:jobgo/presentation/providers/interview_provider.dart';
import 'package:provider/provider.dart';

class CreateInterviewPage extends StatefulWidget {
  const CreateInterviewPage({super.key});

  @override
  State<CreateInterviewPage> createState() =>
      _CreateInterviewPageState();
}

class _CreateInterviewPageState extends State<CreateInterviewPage> {
  final locationCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  DateTime? date;
  String type = 'Offline';

  @override
  Widget build(BuildContext context) {
    final provider = context.read<InterviewProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Tạo lịch phỏng vấn")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(date == null
                  ? "Chọn ngày"
                  : date.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() => date = picked);
                }
              },
            ),

            DropdownButtonFormField(
              value: type,
              items: const [
                DropdownMenuItem(value: 'Online', child: Text('Online')),
                DropdownMenuItem(value: 'Offline', child: Text('Offline')),
              ],
              onChanged: (v) => type = v!,
            ),

            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: "Địa điểm")),
            TextField(controller: contactCtrl, decoration: const InputDecoration(labelText: "Người liên hệ")),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: "Ghi chú")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (date == null) return;

                await provider.createSchedule(
                  date: date!,
                  type: type,
                  location: locationCtrl.text,
                  contactPerson: contactCtrl.text,
                  note: noteCtrl.text,
                  cId: 1, // tạm
                  jId: 1, // tạm
                );

                Navigator.pop(context);
              },
              child: const Text("Tạo"),
            )
          ],
        ),
      ),
    );
  }
}