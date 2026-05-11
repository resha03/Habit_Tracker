import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_widgets.dart';
import '../models/habit.dart';
import 'add_edit_habit_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Habit Tracker'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseService().signOut();
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.home), text: 'Habits'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHabitsTab(),
            const StatsScreen(),
            const SettingsScreen(),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditHabitScreen(),
                    ),
                  );
                  if (result == true) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Habit added successfully')),
                      );
                    }
                  }
                },
                tooltip: 'Add Habit',
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildHabitsTab() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        if (habitProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (habitProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(habitProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => habitProvider.initialize(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredHabits = _selectedCategory == 'All'
            ? habitProvider.habits
            : habitProvider.habits
                .where((h) => h.category == _selectedCategory)
                .toList();

        return Column(
          children: [
            if (!habitProvider.isOnline)
              Container(
                color: Colors.orange.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('Offline Mode - Changes will sync when online'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            CategoryFilter(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
            Expanded(
              child: filteredHabits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox_outlined,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No habits yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first habit to get started',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredHabits.length,
                      itemBuilder: (context, index) {
                        final habit = filteredHabits[index];
                        return HabitCard(
                          habit: habit,
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditHabitScreen(habit: habit),
                              ),
                            );
                            if (result == true && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Habit updated successfully')),
                              );
                            }
                          },
                          onToggle: () {
                            habitProvider.toggleHabitCompletion(habit.id);
                          },
                          onDelete: () {
                            _showDeleteDialog(context, habit, habitProvider);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Habit habit,
    HabitProvider habitProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit?'),
        content:
            Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              habitProvider.deleteHabit(habit.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Habit deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
