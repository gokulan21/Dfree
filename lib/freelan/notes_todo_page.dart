// ignore_for_file: deprecated_member_use, prefer_final_fields

import 'package:flutter/material.dart';
import '../widgets/data_models.dart';

class NotesToDoPage extends StatefulWidget {
  @override
  State<NotesToDoPage> createState() => _NotesToDoPageState();
}

class _NotesToDoPageState extends State<NotesToDoPage> {
  List<Map<String, dynamic>> _tasks = [
    {'task': 'Update portfolio website', 'priority': 'High', 'done': false, 'color': Colors.red},
    {'task': 'Research new design tools', 'priority': 'Done', 'done': true, 'color': Colors.green},
    {'task': 'Schedule client follow-ups', 'priority': 'Medium', 'done': false, 'color': Colors.yellow},
  ];

  List<Map<String, dynamic>> _notes = [
    {
      'title': 'Meeting Ideas',
      'content': 'Discuss new project scope with TechCorp. Focus on mobile-first approach and accessibility features.',
      'date': 'Nov 23'
    },
    {
      'title': 'Design Inspiration',
      'content': 'Gradient backgrounds with glassmorphism effects. Check out Dribbble for more examples.',
      'date': 'Nov 22'
    },
  ];

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    _noteTitleController.dispose();
    _noteContentController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    String selectedPriority = 'Medium';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: bgSecondary,
              title: const Text(
                'Add New Task',
                style: TextStyle(color: textWhite),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Description',
                    style: TextStyle(
                      color: textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _taskController,
                    style: const TextStyle(color: textWhite),
                    decoration: InputDecoration(
                      hintText: 'Enter task description...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF1F2937),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: accentCyan, width: 2),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Priority Level',
                    style: TextStyle(
                      color: textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPriority,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1F2937),
                        style: const TextStyle(color: textWhite),
                        items: [
                          DropdownMenuItem(
                            value: 'High',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('High Priority'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Medium',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.yellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Medium Priority'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Low',
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Low Priority'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              selectedPriority = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _taskController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_taskController.text.trim().isNotEmpty) {
                      _addNewTask(_taskController.text.trim(), selectedPriority);
                      _taskController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPink,
                    foregroundColor: textWhite,
                  ),
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgSecondary,
          title: const Text(
            'Add New Note',
            style: TextStyle(color: textWhite),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Note Title',
                style: TextStyle(
                  color: textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteTitleController,
                style: const TextStyle(color: textWhite),
                decoration: InputDecoration(
                  hintText: 'Enter note title...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: accentCyan, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note Content',
                style: TextStyle(
                  color: textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteContentController,
                style: const TextStyle(color: textWhite),
                decoration: InputDecoration(
                  hintText: 'Enter your note...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF1F2937),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: accentCyan, width: 2),
                  ),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _noteTitleController.clear();
                _noteContentController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_noteTitleController.text.trim().isNotEmpty &&
                    _noteContentController.text.trim().isNotEmpty) {
                  _addNewNote(
                    _noteTitleController.text.trim(),
                    _noteContentController.text.trim(),
                  );
                  _noteTitleController.clear();
                  _noteContentController.clear();
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentPink,
                foregroundColor: textWhite,
              ),
              child: const Text('Add Note'),
            ),
          ],
        );
      },
    );
  }

  void _addNewTask(String taskDescription, String priority) {
    Color priorityColor;
    switch (priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Low':
        priorityColor = Colors.blue;
        break;
      default:
        priorityColor = Colors.yellow;
    }

    setState(() {
      _tasks.insert(0, {
        'task': taskDescription,
        'priority': priority,
        'done': false,
        'color': priorityColor,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "$taskDescription" added successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNewNote(String title, String content) {
    DateTime now = DateTime.now();
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    String formattedDate = '${months[now.month - 1]} ${now.day}';

    setState(() {
      _notes.insert(0, {
        'title': title,
        'content': content,
        'date': formattedDate,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note "$title" added successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
      if (_tasks[index]['done']) {
        _tasks[index]['priority'] = 'Done';
        _tasks[index]['color'] = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes & To-Do',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textWhite,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1024) {
                  return Column(
                    children: [
                      _buildPersonalTasks(),
                      const SizedBox(height: 16),
                      _buildQuickNotes(),
                    ],
                  );
                } else {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildPersonalTasks()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildQuickNotes()),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTasks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentCyan.withOpacity(0.05),
            accentPink.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Personal Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPink,
                  foregroundColor: textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildTaskList(),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList() {
    return _tasks.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> task = entry.value;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Checkbox(
              value: task['done'] as bool,
              onChanged: (value) => _toggleTaskCompletion(index),
              activeColor: accentPink,
              checkColor: textWhite,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                task['task'] as String,
                style: TextStyle(
                  decoration: (task['done'] as bool) ? TextDecoration.lineThrough : null,
                  color: (task['done'] as bool) ? Colors.grey[500] : textWhite,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (task['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task['priority'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: task['color'] as Color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildQuickNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentCyan.withOpacity(0.05),
            accentPink.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Quick Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddNoteDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPink,
                  foregroundColor: textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildNotesList(),
        ],
      ),
    );
  }

  List<Widget> _buildNotesList() {
    return _notes.map((note) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textWhite,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  note['date'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note['content'] as String,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[300],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }).toList();
  }
}