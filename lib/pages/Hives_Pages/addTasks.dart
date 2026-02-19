import 'package:flutter/material.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/user_models/task_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/utilities/hiveRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:choice/choice.dart';
import 'package:dio/dio.dart';
import 'package:async/async.dart';

class AddTasksBody extends ConsumerStatefulWidget {
  const AddTasksBody({super.key});
  @override
  ConsumerState<AddTasksBody> createState() => _AddTasksBodyState();
}

class _AddTasksBodyState extends ConsumerState<AddTasksBody> {
  int _step = 0;
  GlobalKey<FormState> date = GlobalKey<FormState>();
  GlobalKey<FormState> time = GlobalKey<FormState>();
  TextEditingController taskname = TextEditingController();
  TextEditingController taskdescription = TextEditingController();

  bool _isGoogleTask = false;
  bool _isTradeable = false;

  DateTime dueDate = DateTime.now();
  TimeOfDay dueTime = const TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();
  }

  // List<String> hives = [
  //   'Hive 1',
  //   'Hive 2',
  //   'Hive 3',
  //   'Hive 4',
  //   'Hive 5',
  //   'Hive 6',
  //   'Hive 7',
  //   'Hive 8',
  // ];

  // Future<void> _initializeHivesData() async {
  //   try {
  //     final authState = ref.watch(authProvider);
  //     final authNotifier = ref.read(authProvider.notifier);
  //     Get.snackbar('Hives Data Initialized', 'Your hives data has been successfully initialized.');
  //   } catch (e) {
  //     Get.snackbar('Error Initializing Hives Data', e.toString());
  //   }
  // }


  String? hiveValue;
  void setHiveValue(String? value) {
    setState(() => hiveValue = value);
  }
  String? _difficulty = "Easy Task";

  List<String> Owner = [
    'You',
    'BobyJoe',
    'JoeyBob',
  ];
  List<ChoiceData<String>> ownerValue = [];
  void setOwnerValue(List<ChoiceData<String>> value) {
    setState(() => ownerValue = value);
  }
  final choicesMemoizer = AsyncMemoizer<List<ChoiceData<String>>>();

  Future<List<ChoiceData<String>>> getChoices() async {
    try {
      const url =
          "https://randomuser.me/api/?inc=name,picture,email&results=25";
      final res = await Dio().get(url);
      final data = res.data['results'] as List;
      return Future.value(data.asChoiceData(
        value: (i, e) => e['email'],
        title: (i, e) => e['name']['first'] + ' ' + e['name']['last'],
        image: (i, e) => e['picture']['thumbnail'],
      ));
    } on DioException catch (e) {
      throw ErrorDescription(e.message ?? '');
    }
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step += 1);
    } else {
      // Final action: create task
      _submitTask();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step -= 1);
  }

  Future<void> _submitTask() async {
    final DateTime fullDateTimeAssigned = DateTime.now();

    final DateTime fullDateTimeDue = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      dueTime.hour,
      dueTime.minute,
    );

    Hive? curHive = HiveRepository(ref).currentHive;

    TaskModel newTask = TaskModel(
      task_name: taskname.text, 
      tradeable: _isTradeable, 
      date_assigned: fullDateTimeAssigned, 
      date_due: fullDateTimeDue, 
      taskType: 'Mathematics',
      task_description: taskdescription.text, 
      users_tasked: [], //Placeholder, until user loading is actually coded in the backend
      hive_ID: curHive?.hiveUid ??  'xxxxx', //Placeholder
      hive_name: curHive?.hiveName ?? 'xxx', //Placeholder, 
      difficulty: _difficulty ?? '', 
      gc_task: _isGoogleTask,
    );
    
    await HiveRepository(ref).addAssignedTask(newTask);
    Get.snackbar('Success', 'Task created: ${taskname.text}');
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: taskname,
                  decoration: const InputDecoration(
                    hintText: 'Task Name',
                    constraints: BoxConstraints(
                      maxWidth: 600,
                      minWidth: 50,
                      minHeight: 50,
                      maxHeight: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: taskdescription,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Task Description',
                  ),
                ),
                const SizedBox(height: 10),
                Transform.scale(
                  scale: 1,
                  child: DropdownMenu<TaskDifficultyLabel>(
                    initialSelection: TaskDifficultyLabel.easy,
                    onSelected: (TaskDifficultyLabel? difficulty) {
                      setState(() {
                        _difficulty = difficulty?.label ?? "Easy Task";
                      });
                    },
                    dropdownMenuEntries: TaskDifficultyLabel.entries,
                  ),
                ),
              ]
            ),
          ],
        );
      case 1:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? selectedDate = await showDialog<DateTime>(
                      context: context,
                      builder: (BuildContext context) {
                        return DatePickerDialog(
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                          initialEntryMode: DatePickerEntryMode.input,
                          key: date,
                        );
                      },
                    ) ?? DateTime.now();

                    if (selectedDate != null) {
                      setState(() {
                        dueDate = selectedDate;
                      });
                    } else {
                      Get.snackbar('Error', 'Failure in retrieving the due date');
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.date_range),
                      SizedBox(width: 5),
                      Text("Select Date"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selected: ${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
                      context: context,
                      builder: (BuildContext context) {
                        return TimePickerDialog(
                          initialTime: TimeOfDay.now(),
                          initialEntryMode: TimePickerEntryMode.input,
                          key: time,
                        );
                      },
                    );

                    if (selectedTime != null) {
                      setState(() {
                        dueTime = selectedTime;
                      });
                    } else {
                      Get.snackbar('Error', 'Failure in retrieving the due time');
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.av_timer),
                      SizedBox(width: 5),
                      Text("Select Time"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selected: ${dueTime.hour.toString().padLeft(2, '0')}:${dueTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        );
      case 2:
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<List<ChoiceData<String>>>(
                  initialData: const [],
                  future: choicesMemoizer.runOnce(getChoices),
                  builder: (context, snapshot) {
                    return SizedBox(
                      width: 300,
                      child: Card(
                        color: const Color(0xFFFFDD97),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            appBarTheme: Theme.of(context).appBarTheme.copyWith(
                              iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ),
                          child: PromptedChoice<ChoiceData<String>>.multiple(
                            title: 'Users',
                            clearable: true,
                            error: snapshot.hasError,
                            errorBuilder: ChoiceListError.create(
                              message: snapshot.error.toString(),
                            ),
                            loading: snapshot.connectionState == ConnectionState.waiting,
                            value: ownerValue,
                            onChanged: setOwnerValue,
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (state, i) {
                              final choice = snapshot.data?.elementAt(i);
                              return CheckboxListTile(
                                value: state.selected(choice!),
                                onChanged: state.onSelected(choice),
                                title: Text(choice.title),
                                subtitle: choice.subtitle != null
                                  ? Text(
                                      choice.subtitle!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                                secondary: choice.image != null
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(choice.image!),
                                    )
                                  : null,
                              );
                            },
                            modalHeaderBuilder: ChoiceModal.createHeader(
                              title: const Text('Select Users', style: TextStyle(fontSize: 50, fontWeight: FontWeight.normal),),
                              actionsBuilder: [
                                (state) {
                                  final values = snapshot.data!;
                                  return Checkbox(
                                    value: state.selectedMany(values),
                                    onChanged: state.onSelectedMany(values),
                                    tristate: true,
                                  );
                                },
                                ChoiceModal.createSpacer(width: 25),
                              ],
                            ),
                            promptDelegate: ChoicePrompt.delegateBottomSheet(),
                            anchorBuilder: ChoiceAnchor.create(valueTruncate: 1),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Google Task?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Transform.scale(
                        scale: 1.5,
                        child: Switch(
                          value: _isGoogleTask,
                          onChanged: (val) => setState(() => _isGoogleTask = val),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tradeable?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Transform.scale(
                        scale: 1.5,
                        child: Switch(
                          value: _isTradeable,
                          onChanged: (val) => setState(() => _isTradeable = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_step + 1}/3',
                      style: const TextStyle(fontSize: 18, color: Colors.green)),
                  TextButton(
                    onPressed: () {}, // Navigate back from AddTasks
                    child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildStepContent()),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _back,
                        child: const Text('Back'),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _step < 2 ? const Color.fromARGB(255, 0, 0, 0) : const Color(0xFFF3A31A),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _step < 2 ? const SizedBox.shrink() 
                          : const Icon(Icons.add_task, color: Colors.black, size: 25,),
                          _step < 2 ? const SizedBox.shrink() : const SizedBox(width: 8),
                          Text(_step < 2 ? 'Next' : 'Create', style: _step < 2 ? const TextStyle(color: Colors.white) : const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef TaskDifficulty = DropdownMenuEntry<TaskDifficultyLabel>;

enum TaskDifficultyLabel {
  easy('Easy Task'),
  medium('Medium Task'),
  hard('Hard Task');

  const TaskDifficultyLabel(this.label);
  final String label;

  static final List<DropdownMenuEntry<TaskDifficultyLabel>> entries =
      TaskDifficultyLabel.values.map((taskDifficulty) {
    return DropdownMenuEntry<TaskDifficultyLabel>(
      value: taskDifficulty,
      label: taskDifficulty.label,
    );
  }).toList();
}