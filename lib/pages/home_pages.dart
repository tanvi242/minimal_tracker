
import 'package:flutter/material.dart';
import 'package:minimal_tracker/components/habit_tile.dart';
import 'package:minimal_tracker/components/my_drawer.dart';
import 'package:minimal_tracker/components/my_heat_map.dart';
import 'package:minimal_tracker/database/habit_database.dart';
import 'package:minimal_tracker/models/habit.dart';
import 'package:minimal_tracker/utilities/habit_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // read existing habits on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitDatabase>(context, listen: false).readHabits();
    });
  }

  // Text Controller
  final TextEditingController textEditingController = TextEditingController();

  // create new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          decoration: InputDecoration(
            hintText: "Create a new habit",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            )
          ),
          textAlign: TextAlign.center,
          controller: textEditingController,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Save button
              MaterialButton(
                onPressed: () {
                  // get new habit name
                  String newHabitName = textEditingController.text.trim();
                  if (newHabitName.isNotEmpty) {
                    // save to database
                    context.read<HabitDatabase>().addHabit(newHabitName);
                  } else {
                    // Optional: Show a snackbar or toast for empty input
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Habit name cannot be empty")),
                    );
                  }
                  // pop dialog
                  Navigator.pop(context);
                  // clear controller
                  textEditingController.clear();
                },
                child: const Text("Save"),
              ),
              // Cancel button
              MaterialButton(
                onPressed: () {
                  // pop dialog
                  Navigator.pop(context);
                  // clear controller
                  textEditingController.clear();
                },
                child: const Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // check habit on & off
  void checkHabitOnOff(bool? value, Habit habit) {
      // update habit completion status
      if (value != null){
       context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
      }
    }

  // edit habit box
  void editHabitBox(Habit habit){
    // set the controller's text to the habit's current name
    textEditingController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(controller: textEditingController,),
          actions: [
            // Save button
            MaterialButton(
              onPressed: () {
                // get new habit name
                String newHabitName = textEditingController.text.trim();
                if (newHabitName.isNotEmpty) {
                  // save to database
                  context.read<HabitDatabase>().updateHabitName(habit.id,newHabitName);
                } else {
                  // Optional: Show a snackbar or toast for empty input
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Habit name cannot be empty")),
                  );
                }
                // pop dialog
                Navigator.pop(context);
                // clear controller
                textEditingController.clear();
              },
              child: const Text("Save"),
            ),
            // Cancel button
            MaterialButton(
              onPressed: () {
                // pop dialog
                Navigator.pop(context);
                // clear controller
                textEditingController.clear();
              },
              child: const Text("Cancel"),
            ),
          ],
        ));
  }

  // delete habit box
  void deleteHabitBox(Habit habit){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Are you sure?"),
          actions: [
            // delete button
            MaterialButton(
              onPressed: () {

                // save to database
                context.
                  read<HabitDatabase>().
                  deleteHabit(habit.id);

                // pop dialog
                Navigator.pop(context);

              },
              child: const Text("Delete"),
            ),

            // Cancel button
            MaterialButton(
              onPressed: () {
                // pop dialog
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        ));
  }

  // check if habit is completed today
  bool isHabitCompletedToday(List<DateTime> completedDays) {
    final now = DateTime.now();
    return completedDays.any((date) =>
    date.year == now.year &&
        date.month == now.month &&
        date.day == now.day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation:0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          // H E A T - M A P
          _buildHeatMap(),
          // H A B I T L I S T
          _buildHabitList(),
        ],
      ),
    );
  }
  // build heat map
  Widget _buildHeatMap(){
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return Heat Map UI
    return FutureBuilder(
        future: habitDatabase.getFirstLauncgDate(),
        builder: (context, snapshot){
          // once data is available --> build heatmap
          if (snapshot.hasData){
            return MyHeatMap(
                startDate: snapshot.data!,
                datasets: prepHeatMapDataset(currentHabits),
            );
          }
          else{
            // handle case where no data is returned
            return Container();
          }
        },
    );
  }


  // build habit list
  Widget _buildHabitList() {
    // habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // return list of habits UI
    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // get each individual habit
        final habit = currentHabits[index];

        // check if the habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // return habit tile UI
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value,habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) =>deleteHabitBox(habit),
        );
      },
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}