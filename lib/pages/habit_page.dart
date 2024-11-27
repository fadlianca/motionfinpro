// ignore_for_file: unused_local_variable, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:motion/components/my_habit_tile.dart';
import 'package:motion/components/my_heat_map.dart';
import 'package:motion/models/habit.dart';
import 'package:provider/provider.dart';
import '../components/my_theme_switch.dart';
import '../database/habit_database.dart';
import '../util/habit_util.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  @override
  void initState() {
    super.initState();
    // read existing habit on app
    Provider.of<HabitDatabase>(context, listen: false).loadHabits();
  }

  // text controller
  final TextEditingController textController = TextEditingController();

  //buat habit baru
  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: "Create New Habit"),
              ),
              actions: [
                // save button
                MaterialButton(
                  onPressed: () {
                    //get the new habit name
                    String newHabitName = textController.text;

                    // save to db
                    context.read<HabitDatabase>().createHabit(newHabitName);

                    // pop box
                    Navigator.pop(context);

                    // clear controller
                    textController.clear();
                  },
                  child: const Text('Save'),
                ),

                // cancel button
                MaterialButton(
                  onPressed: () {
                    // pop box
                    Navigator.pop(context);

                    // clear controller
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                )
              ],
            ));
  }

  //check on and off
  void checkHabitOnOff(bool? value, Habit habit) {
    //habit completetion status
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  //edit habit box
  void editHabitBox(Habit habit) {
    //set the contorller text to the habit current name
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                // save button
                MaterialButton(
                  onPressed: () {
                    //get the new habit name
                    String newHabitName = textController.text;

                    // save to db
                    context
                        .read<HabitDatabase>()
                        .updateHabitName(habit.id, newHabitName);

                    // pop box
                    Navigator.pop(context);

                    // clear controller
                    textController.clear();
                  },
                  child: const Text('Save'),
                ),

                // cancel button
                MaterialButton(
                  onPressed: () {
                    // pop box
                    Navigator.pop(context);

                    // clear controller
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                )
              ],
            ));
  }

  //delete habit box
  void deleteHabitBox(Habit habit) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Apakah kamu ingin menghapus ini?"),
              actions: [
                // delete button
                MaterialButton(
                  onPressed: () {
                    // save to db
                    context.read<HabitDatabase>().deleteHabit(habit.id);

                    // pop box
                    Navigator.pop(context);
                  },
                  child: const Text('Delete'),
                ),

                // cancel button
                MaterialButton(
                  onPressed: () {
                    // pop box
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 20,
        title: Text(
          "MOTION",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ThemeSwitcher(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ListView(children: [
        _buildHeatMap(),
        _buildHabitList(),
      ]),
    );
  }

  //build heat map
  Widget _buildHeatMap() {
    //habit datatbase
    final habitDatabase = context.watch<HabitDatabase>();

    //currentHabits
    List<Habit> currentHabits = habitDatabase.habits;

    //return heat map UI
    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        //once data availible build heatmap
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataset(currentHabits),
          );
        }

        //handle case where no data is returned
        else {
          return Container();
        }
      },
    );
  }

  //build habit list
  Widget _buildHabitList() {
    //habit db
    return Consumer<HabitDatabase>(builder: (context, habitDatabase, child) {
      //current habits
      List<Habit> currentHabits = habitDatabase.habits;

      // return list of habits UI
      return ListView.builder(
          itemCount: currentHabits.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // get each individual habit
            final habit = currentHabits[index];

            // check if the habit complete today
            bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

            //return habit tile UI
            return MyHabitTile(
              text: habit.name,
              isCompleted: isCompletedToday,
              onChanged: (value) => checkHabitOnOff(value, habit),
              editHabit: (context) => editHabitBox(habit),
              deleteHabit: (context) => deleteHabitBox(habit),
            );
          });
    });
  }
}
