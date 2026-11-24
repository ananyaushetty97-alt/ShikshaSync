import 'package:flutter/material.dart';
import '../../models/student.dart';
import '../../services/db_service.dart';
import 'lesson_player.dart';

class StudentSelectScreen extends StatefulWidget {
  const StudentSelectScreen({super.key});

  @override
  State<StudentSelectScreen> createState() => _StudentSelectScreenState();
}

class _StudentSelectScreenState extends State<StudentSelectScreen> {
  final DbService _db = DbService();
  final _pinController = TextEditingController();
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await _db.getAllStudents();
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'ShikshaSync',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your profile',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_students.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_add, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'No students yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _showAddStudentDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Student'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _students.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _students.length) {
                              return _buildAddStudentCard();
                            }
                            return _buildStudentCard(_students[index]);
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return GestureDetector(
      onTap: () => _showPinDialog(student),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(student.avatarPath),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 12),
            Text(
              student.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Grade ${student.grade} • ${student.language.toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStudentCard() {
    return GestureDetector(
      onTap: _showAddStudentDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E7D32), width: 2, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 48, color: Color(0xFF2E7D32)),
            SizedBox(height: 12),
            Text(
              'Add Student',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameController = TextEditingController();
    String selectedAvatar = 'assets/avatars/avatar1.svg';
    String selectedLanguage = 'kn';
    int selectedGrade = 6;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  decoration: const InputDecoration(labelText: '4-Digit PIN'),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedGrade,
                  decoration: const InputDecoration(labelText: 'Grade'),
                  items: List.generate(8, (i) => i + 1)
                      .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
                      .toList(),
                  onChanged: (v) => setState(() => selectedGrade = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedLanguage,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: const [
                    DropdownMenuItem(value: 'kn', child: Text('Kannada')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                    DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (v) => setState(() => selectedLanguage = v!),
                ),
                const SizedBox(height: 16),
                const Text('Select Avatar:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: List.generate(4, (i) => 'assets/avatars/avatar${i + 1}.svg')
                      .map((avatar) => GestureDetector(
                            onTap: () => setState(() => selectedAvatar = avatar),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedAvatar == avatar
                                      ? const Color(0xFF2E7D32)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: AssetImage(avatar),
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || _pinController.text.length != 4) return;

                final student = Student(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  avatarPath: selectedAvatar,
                  pin: _pinController.text,
                  grade: selectedGrade,
                  language: selectedLanguage,
                  createdAt: DateTime.now(),
                );

                await _db.insertStudent(student);
                _pinController.clear();
                Navigator.pop(context);
                _loadStudents();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog(Student student) {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter PIN for ${student.name}'),
        content: TextField(
          controller: _pinController,
          decoration: const InputDecoration(labelText: '4-Digit PIN'),
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_pinController.text == student.pin) {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonPlayerScreen(student: student),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN')),
                );
              }
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );
  }
}