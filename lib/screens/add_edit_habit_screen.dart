import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddEditHabitScreen({Key? key, this.habit}) : super(key: key);

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _goalDaysController;
  late AnimationController _animationController;

  String _selectedCategory = 'Exercise';
  String? _selectedColor;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();

    if (widget.habit != null) {
      _nameController = TextEditingController(text: widget.habit!.name);
      _descriptionController =
          TextEditingController(text: widget.habit!.description);
      _goalDaysController =
          TextEditingController(text: widget.habit!.goalDays.toString());
      _selectedCategory = widget.habit!.category;
      _selectedColor = widget.habit!.color;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _goalDaysController = TextEditingController(text: '30');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalDaysController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Create Habit' : 'Edit Habit'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Field
                  Text(
                    'Habit Name *',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Morning Exercise',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                    validator: Validators.validateHabitName,
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  Text(
                    'Description',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Add a description (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: Validators.validateDescription,
                  ),
                  const SizedBox(height: 24),

                  // Category Selection
                  Text(
                    'Category *',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: AppConstants.habitCategories
                          .map((category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppConstants
                                        .categoryColors[category],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(category),
                              ],
                            ),
                          ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Goal Days Field
                  Text(
                    'Goal Days *',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _goalDaysController,
                    decoration: InputDecoration(
                      hintText: 'e.g., 30',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixText: 'days',
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateGoalDays,
                  ),
                  const SizedBox(height: 24),

                  // Color Preview
                  Text(
                    'Color',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppConstants.categoryColors.values
                            .map((color) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() =>
                                  _selectedColor = color.toString());
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _selectedColor == color.toString()
                                          ? Colors.black
                                          : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveHabit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            widget.habit == null
                                ? 'Create Habit'
                                : 'Update Habit',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final habitProvider = context.read<HabitProvider>();
    final goalDays = int.parse(_goalDaysController.text);

    if (widget.habit == null) {
      // Create new habit
      final newHabit = Habit(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        goalDays: goalDays,
        color: _selectedColor,
      );
      habitProvider.addHabit(newHabit);
    } else {
      // Update existing habit
      final updatedHabit = widget.habit!.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        goalDays: goalDays,
        color: _selectedColor,
      );
      habitProvider.updateHabit(updatedHabit);
    }

    Navigator.pop(context, true);
  }
}
