class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final String? assigned_to;
  final String? dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.assigned_to,
    required this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      status: json['status'],
      assigned_to: json['assigned_to'],
      dueDate: json['due_date'],
    );
  }
}
