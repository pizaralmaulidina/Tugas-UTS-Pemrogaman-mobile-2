import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> with SingleTickerProviderStateMixin {
  final List<TodoItem> _todoItems = [
    TodoItem(
      title: 'Beli bahan makanan', 
      isCompleted: false,
      priority: Priority.medium,
      category: 'Belanja',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    TodoItem(
      title: 'Mengerjakan tugas Flutter', 
      isCompleted: true,
      priority: Priority.high,
      category: 'Pendidikan',
      dueDate: DateTime.now(),
    ),
    TodoItem(
      title: 'Olahraga pagi', 
      isCompleted: false,
      priority: Priority.high,
      category: 'Kesehatan',
      dueDate: DateTime.now().add(const Duration(hours: 2)),
    ),
    TodoItem(
      title: 'Baca buku 30 menit', 
      isCompleted: false,
      priority: Priority.low,
      category: 'Hobi',
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
    TodoItem(
      title: 'Meeting dengan klien', 
      isCompleted: false,
      priority: Priority.high,
      category: 'Kerja',
      dueDate: DateTime.now().add(const Duration(hours: 4)),
    ),
    TodoItem(
      title: 'Renovasi kamar mandi', 
      isCompleted: true,
      priority: Priority.medium,
      category: 'Rumah',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final TextEditingController _textEditingController = TextEditingController();
  late AnimationController _animationController;
  bool _showCompleted = true;
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', 'Prioritas Tinggi', 'Hari Ini', 'Belanja', 'Kerja'];
  final Map<String, Color> _categoryColors = {
    'Belanja': Colors.orange,
    'Pendidikan': Colors.blue,
    'Kesehatan': Colors.green,
    'Hobi': Colors.purple,
    'Kerja': Colors.red,
    'Rumah': Colors.brown,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addTodoItem(String title) {
    if (title.isNotEmpty) {
      setState(() {
        _todoItems.insert(0, TodoItem(
          title: title, 
          isCompleted: false,
          priority: Priority.medium,
          category: 'Umum',
        ));
      });
      _textEditingController.clear();
      _showSuccessSnackBar('Tugas berhasil ditambahkan!');
    }
  }

  void _removeTodoItem(int index) {
    final removedItem = _todoItems[index];
    setState(() {
      _todoItems.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tugas "${removedItem.title}" dihapus'),
        action: SnackBarAction(
          label: 'Batal',
          onPressed: () {
            setState(() {
              _todoItems.insert(index, removedItem);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].isCompleted = !_todoItems[index].isCompleted;
      if (_todoItems[index].isCompleted) {
        _todoItems[index].completedAt = DateTime.now();
      }
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  List<TodoItem> _getFilteredTasks() {
    List<TodoItem> filtered = _todoItems;
    
    if (!_showCompleted) {
      filtered = filtered.where((item) => !item.isCompleted).toList();
    }
    
    switch (_selectedFilter) {
      case 0: // Semua
        break;
      case 1: // Prioritas Tinggi
        filtered = filtered.where((item) => item.priority == Priority.high).toList();
        break;
      case 2: // Hari Ini
        final today = DateTime.now();
        filtered = filtered.where((item) => 
          item.dueDate != null &&
          item.dueDate!.year == today.year &&
          item.dueDate!.month == today.month &&
          item.dueDate!.day == today.day
        ).toList();
        break;
      case 3: // Belanja
        filtered = filtered.where((item) => item.category == 'Belanja').toList();
        break;
      case 4: // Kerja
        filtered = filtered.where((item) => item.category == 'Kerja').toList();
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();
    final completedCount = _todoItems.where((item) => item.isCompleted).length;
    final totalCount = _todoItems.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('TaskFlow'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildSettingsSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Tugas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      icon: Icons.list_alt,
                      value: totalCount.toString(),
                      label: 'Total Tugas',
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle,
                      value: completedCount.toString(),
                      label: 'Selesai',
                      color: Colors.green,
                    ),
                    _buildStatCard(
                      icon: Icons.access_time,
                      value: '${(progress * 100).toInt()}%',
                      label: 'Progress',
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                LinearProgressIndicator(
                  value: progress.toDouble(),
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_filters[index]),
                      selected: _selectedFilter == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? index : 0;
                        });
                      },
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // Input section dengan desain menarik
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Apa yang perlu dilakukan?',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (value) {
                        _addTodoItem(value);
                      },
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          _addTodoItem(_textEditingController.text);
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        splashRadius: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Toggle completed tasks
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tugas Saya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Sembunyikan Selesai',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Switch.adaptive(
                      value: !_showCompleted,
                      onChanged: (value) {
                        setState(() {
                          _showCompleted = !value;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // List section dengan animasi
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    index * 0.1,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0,
                                  end: 1,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(
                                      index * 0.1,
                                      1.0,
                                      curve: Curves.easeIn,
                                    ),
                                  ),
                                ),
                                child: TodoListItem(
                                  todoItem: filteredTasks[index],
                                  index: _todoItems.indexWhere((item) => item.id == filteredTasks[index].id),
                                  onToggle: _toggleTodoItem,
                                  onRemove: _removeTodoItem,
                                  categoryColors: _categoryColors,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTodoDialog(
              onAdd: _addTodoItem,
              categoryColors: _categoryColors,
            ),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Type get num => num;

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_tasks.png', // Ganti dengan asset Anda
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            color: Colors.blue.withOpacity(0.3),
            colorBlendMode: BlendMode.srcATop,
          ),
          const SizedBox(height: 20),
          const Text(
            'Tidak ada tugas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tambahkan tugas baru untuk mulai mengatur hari Anda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddTodoDialog(
                  onAdd: _addTodoItem,
                  categoryColors: _categoryColors,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 20),
                SizedBox(width: 8),
                Text('Tambah Tugas Baru'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: const Text('Notifikasi'),
            trailing: Switch.adaptive(
              value: true,
              onChanged: (value) {},
              activeColor: Colors.blue,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: Colors.purple),
            title: const Text('Mode Gelap'),
            trailing: Switch.adaptive(
              value: false,
              onChanged: (value) {},
              activeColor: Colors.blue,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Hapus Semua Tugas Selesai'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation();
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua tugas yang sudah selesai?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _todoItems.removeWhere((item) => item.isCompleted);
              });
              Navigator.pop(context);
              _showSuccessSnackBar('Tugas selesai telah dihapus');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// Enums dan model yang diperbarui
enum Priority { low, medium, high }

class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  Priority priority;
  String category;
  DateTime? dueDate;
  DateTime? createdAt;
  DateTime? completedAt;
  
  TodoItem({
    String? id,
    required this.title,
    required this.isCompleted,
    this.priority = Priority.medium,
    this.category = 'Umum',
    this.dueDate,
    this.createdAt,
    this.completedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
}

class TodoListItem extends StatelessWidget {
  final TodoItem todoItem;
  final int index;
  final Function(int) onToggle;
  final Function(int) onRemove;
  final Map<String, Color> categoryColors;
  
  const TodoListItem({
    super.key,
    required this.todoItem,
    required this.index,
    required this.onToggle,
    required this.onRemove,
    required this.categoryColors,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {
            onToggle(index);
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox dengan animasi
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: todoItem.isCompleted ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: todoItem.isCompleted ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: todoItem.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // Konten
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              todoItem.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: todoItem.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: todoItem.isCompleted ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                          // Priority indicator
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(todoItem.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Row(
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: categoryColors[todoItem.category]?.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: categoryColors[todoItem.category]?.withOpacity(0.3) ?? Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              todoItem.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: categoryColors[todoItem.category] ?? Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Due date
                          if (todoItem.dueDate != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: _getDueDateColor(todoItem.dueDate!),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDueDate(todoItem.dueDate!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getDueDateColor(todoItem.dueDate!),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Delete button
                IconButton(
                  onPressed: () {
                    onRemove(index);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  splashRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }
  
  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays < 0) {
      return Colors.red; // Telat
    } else if (difference.inDays == 0) {
      return Colors.orange; // Hari ini
    } else if (difference.inDays <= 2) {
      return Colors.orange[700]!; // 1-2 hari lagi
    } else {
      return Colors.green; // Masih lama
    }
  }
  
  String _formatDueDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);

  final difference = target.difference(today).inDays;

  if (difference == 0) return "Hari ini";
  if (difference == 1) return "Besok";
  if (difference < 0) return "${difference.abs()} hari lalu";

  return "$difference hari lagi";
}
  
}

class AddTodoDialog extends StatefulWidget {
  final Function(String) onAdd;
  final Map<String, Color> categoryColors;
  
  const AddTodoDialog({super.key, required this.onAdd, required this.categoryColors});
  
  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'Umum';
  Priority _selectedPriority = Priority.medium;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tambah Tugas Baru',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Masukkan tugas...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.categoryColors.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(entry.key),
                          selected: _selectedCategory == entry.key,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = entry.key;
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: entry.value.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedCategory == entry.key 
                                ? entry.value 
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedCategory == entry.key
                                  ? entry.value
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Prioritas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildPriorityButton(
                        Priority.high,
                        'Tinggi',
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPriorityButton(
                        Priority.medium,
                        'Sedang',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildPriorityButton(
                        Priority.low,
                        'Rendah',
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    
                    const SizedBox(width: 15),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            widget.onAdd(_controller.text);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriorityButton(Priority priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        foregroundColor: isSelected ? color : Colors.grey,
        side: BorderSide(
          color: isSelected ? color : Colors.grey[300]!,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}