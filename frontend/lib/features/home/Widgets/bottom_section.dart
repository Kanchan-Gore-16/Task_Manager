import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../task_model.dart';
import '../../task_provider.dart';

class TaskFormBottomSheet extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormBottomSheet({super.key, this.task});

  @override
  ConsumerState<TaskFormBottomSheet> createState() =>
      _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends ConsumerState<TaskFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _assignedController = TextEditingController();

  late String _category;
  late String _priority;
  late String _status;

  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      // 🔹 EDIT MODE
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _assignedController.text = widget.task!.assigned_to ?? '';

      _category = widget.task!.category;
      _priority = widget.task!.priority;
      _status = widget.task!.status;

      if (widget.task!.dueDate != null) {
        _dueDate = DateTime.tryParse(widget.task!.dueDate!);
      }
    } else {
      _category = "";
      _priority = "";
      _status = "";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _assignedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_saving,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          builder: (_, controller) => SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Header
                    Text(
                      widget.task == null ? "Create Task" : "Edit Task",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Title *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Title required"
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Description
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description *",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Description required"
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Category
                    if (widget.task != null) ...[
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: "Category",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'scheduling',
                            child: Text('Scheduling'),
                          ),
                          DropdownMenuItem(
                            value: 'finance',
                            child: Text('Finance'),
                          ),
                          DropdownMenuItem(
                            value: 'technical',
                            child: Text('Technical'),
                          ),
                          DropdownMenuItem(
                            value: 'safety',
                            child: Text('Safety'),
                          ),
                          DropdownMenuItem(
                            value: 'general',
                            child: Text('General'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 🔹 Priority
                    if (widget.task != null) ...[
                      DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: "Priority",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'high', child: Text('High')),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                        ],
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 🔹 Status (EDIT ONLY)
                    if (widget.task != null) ...[
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: "Status",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('In Progress'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Completed'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 🔹 Due Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _dueDate == null
                            ? "Select Due Date"
                            : "Due: ${_dueDate!.toLocal().toString().split(' ')[0]}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _dueDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Assigned To
                    TextField(
                      controller: _assignedController,
                      decoration: const InputDecoration(
                        labelText: "Assigned To",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Save / Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }

                                setState(() => _saving = true);

                                try {
                                  if (widget.task == null) {
                                    // CREATE
                                    await ref
                                        .read(taskProvider.notifier)
                                        .createTask(
                                          title: _titleController.text.trim(),
                                          description: _descController.text
                                              .trim(),
                                          assignedTo:
                                              _assignedController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _assignedController.text.trim(),
                                          dueDate: _dueDate
                                              ?.toUtc()
                                              .toIso8601String(),
                                        );
                                  } else {
                                    // EDIT
                                    await ref
                                        .read(taskProvider.notifier)
                                        .editTask(
                                          id: widget.task!.id,
                                          title: _titleController.text.trim(),
                                          description: _descController.text
                                              .trim(),
                                          category: _category,
                                          priority: _priority,
                                          status: _status,
                                          assignedTo:
                                              _assignedController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _assignedController.text.trim(),
                                          dueDate: _dueDate
                                              ?.toUtc()
                                              .toIso8601String(),
                                        );
                                  }

                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          widget.task == null
                                              ? "Failed to create task: $e"
                                              : "Failed to update task: $e",
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _saving = false);
                                  }
                                }
                              },
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.task == null
                                    ? "Save Task"
                                    : "Update Task",
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
