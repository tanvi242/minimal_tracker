import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  final void Function(bool?)? onChanged;
  final void Function(BuildContext)? editHabit;
  final void Function(BuildContext)? deleteHabit;

  const MyHabitTile({
    super.key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              // Edit Option
              SlidableAction(
                  onPressed: editHabit,
                  backgroundColor: Colors.grey.shade800,
                  icon: Icons.edit,
                  borderRadius: BorderRadius.circular(10),
              ),

              // Delete Option
              SlidableAction(
                onPressed: deleteHabit,
                backgroundColor: Colors.red.shade800,
                icon: Icons.delete,
                borderRadius: BorderRadius.circular(10),
              )
            ]
        ),
        child: GestureDetector(
          onTap: (){
            if(onChanged != null){
              // toggle completion status
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCompleted? Colors.green : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            margin: EdgeInsets.all(12),

            child: ListTile(
                title: Text(text, style: TextStyle(color: isCompleted ? Colors.white : Theme.of(context).colorScheme.inversePrimary)),
              leading: Checkbox(
                  value: isCompleted,
                  onChanged: onChanged,
                activeColor: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


