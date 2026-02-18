import 'dart:math';

import 'package:choice/choice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/enums/navigation_enum.dart';
import 'package:flutter_app/models/group_models/hive.dart';
import 'package:flutter_app/models/group_models/hive_default_settings_model.dart';
import 'package:flutter_app/providers/hive_service_provider.dart';
import 'package:flutter_app/utilities/hiveRepository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart';
import 'package:get/route_manager.dart';

class CreateHive extends ConsumerStatefulWidget {
  final Function(NavigationPage) onNavigate;
  const CreateHive({super.key, required this.onNavigate});
  @override
  ConsumerState<CreateHive> createState() => _CreateHiveState();
}

class _CreateHiveState extends ConsumerState<CreateHive> {
  TextEditingController hiveName = TextEditingController();
  TextEditingController hiveDesc = TextEditingController();
  String _subject = "Mathematics";
  int _step = 0;
  final AsyncMemoizer<List<ChoiceData<String>>> _choicesMemoizer =
      AsyncMemoizer();
  List<ChoiceData<String>> ownerValue = [];
  Color _selectedColor = const Color(0xFFFFB743);
  IconData _selectedIcon = Icons.group;
  
  bool _isPrivate = false;
  bool _allowInvites = true;
  bool _nectarCenter = true;
  bool _taskTrading = true;
  bool _taskAddition = true;
  bool _taskRemoval = true;
  bool _aiSummary = false;
  bool _hiveNotifications = true;
  final List<Color> _colorOptions = [
    Color(0xFFFFB743),
    Color(0xFFFF7700),
    Color(0xFFFFF600),
    Color(0xFFFF00EE),
    Colors.blue,
    Colors.green,
  ];
  final List<IconData> _iconOptions = [
    Icons.group,
    Icons.bolt,
    Icons.school,
    Icons.auto_awesome,
    Icons.sports_soccer,
    Icons.music_note,
  ];
  @override
  void initState() {
    super.initState();
  }

  createHiveSuccessPopup() async {
    final result = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Success! You have created your first hive! Congratulations on officially becoming a beekeeper."), 
        //Make this an achievement and physically initiate the achievement reception later.
        content: const Text("Do you wish to continue to the hive, or return to the home page?"),
        actions: [
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context, true);
            },
            child: const Text("YES"),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context, false);
            }, 
            child: const Text("NO"),
          ),
        ]
      ),
    );
      if(result == true){
        widget.onNavigate(NavigationPage.hives);
      } else {
        widget.onNavigate(NavigationPage.home);
      }
  }

  @override
  Widget build(BuildContext context) {
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

    void setOwnerValue(List<ChoiceData<String>> value) {
      setState(() => ownerValue = value);
    }

    Widget _buildStepContent() {
      switch (_step) {
        case 0:
          return ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: hiveName,
                    decoration: const InputDecoration(
                      hintText: 'Hive Name',
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
                    controller: hiveDesc,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Hive Description',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Transform.scale(
                    scale: 1,
                    child: DropdownMenu<SubjectLabel>(
                      initialSelection: SubjectLabel.mathematics,
                      onSelected: (SubjectLabel? subject) {
                        setState(() {
                          _subject = subject?.label ?? "Mathematics";
                        });
                      },
                      dropdownMenuEntries: SubjectLabel.entries,
                    ),
                  ),
                ]
              ),
            ],
          );
        case 1:
          return ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            children: [
              const Text('Choose Hive Color', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colorOptions.map((c) {
                  final selected = c == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Choose Hive Icon', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _iconOptions.map((ic) {
                  final selected = ic == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = ic),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: selected
                            ? _selectedColor.withAlpha(40)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              selected ? _selectedColor : Colors.grey.shade300,
                        ),
                      ),
                      child: Icon(ic, size: 32, color: _selectedColor),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        default:
          return FutureBuilder<List<ChoiceData<String>>>(
            initialData: const [],
            future: _choicesMemoizer.runOnce(getChoices),
            builder: (context, snapshot) {
              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                children: [
                  SizedBox(
                    width: 600,
                    child: Card(
                      color: const Color(0xFFFFB743),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                                iconTheme: const IconThemeData(
                                    color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                        ),
                        child: PromptedChoice<ChoiceData<String>>.multiple(
                          title: 'Hive Members',
                          clearable: true,
                          error: snapshot.hasError,
                          errorBuilder: ChoiceListError.create(
                            message: snapshot.error.toString(),
                          ),
                          loading: snapshot.connectionState ==
                              ConnectionState.waiting,
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
                                      backgroundImage:
                                          NetworkImage(choice.image!),
                                    )
                                  : null,
                            );
                          },
                          modalHeaderBuilder: ChoiceModal.createHeader(
                            title: const Text(
                              'Select Hive Members',
                              style: TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.normal),
                            ),
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
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Nectar Center',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontFamily: 'Jomhuria'),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: Switch(
                            value: _nectarCenter,
                            onChanged: (val) =>
                                setState(() => _nectarCenter = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Task Trading',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontFamily: 'Jomhuria'),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: Switch(
                            value: _taskTrading,
                            onChanged: (val) =>
                                setState(() => _taskTrading = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Task Addition',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontFamily: 'Jomhuria'),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: Switch(
                            value: _taskAddition,
                            onChanged: (val) =>
                                setState(() => _taskAddition = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Task Removal',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontFamily: 'Jomhuria'),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: Switch(
                            value: _taskRemoval,
                            onChanged: (val) =>
                                setState(() => _taskRemoval = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI Summary',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontFamily: 'Jomhuria'),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: Switch(
                            value: _aiSummary,
                            onChanged: (val) =>
                                setState(() => _aiSummary = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hive Notifications',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontFamily: 'Jomhuria'),
                        ),
                        Transform.scale(
                          scale: 1.5,
                          child: Switch(
                            value: _hiveNotifications,
                            onChanged: (val) =>
                                setState(() => _hiveNotifications = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
      }
    }

    void _next() {
      if (_step < 2) {
        setState(() => _step += 1);
      } else {
        // Final action: create hive
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Create Hive action')));
      }
    }

    void _back() {
      if (_step > 0) setState(() => _step -= 1);
    }

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
                    onPressed: () => widget.onNavigate(NavigationPage.hives),
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
                      onPressed: _step < 2 ? _next : () async {
                        final summary = {
                          'name': hiveName.text,
                          'description': hiveDesc.text,
                          'subject': _subject,
                          'color': _selectedColor,
                          'icon': _selectedIcon.codePoint,
                          'members': ownerValue.map((e) => e.value).toList(),
                          'private': _isPrivate,
                          'allowInvites': _allowInvites,
                        };
                        final defaultSettingsDetails = HiveDefaultSettingsModel(
                          additionEnabled: _taskAddition, 
                          appreciationEnabled: _nectarCenter, 
                          logEnabled: _hiveNotifications, 
                          taskRemovalEnabled: _taskRemoval, 
                          summaryEnabled: _aiSummary, 
                          tradingEnabled: _taskTrading);

                        String generateJoinCode([int length = 6]) {
                          const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                          final rnd = Random.secure();
                          return List.generate(length, (_) => chars[rnd.nextInt(chars.length)]).join();
                        }

                        final hive = Hive(
                          user_role: '', //Jeevanth needs to add this to the UI itself 
                          hive_name: hiveName.text, 
                          hive_description: hiveDesc.text, 
                          hive_subject: _subject, 
                          default_settings: defaultSettingsDetails,
                          teacher_led: false, //Change this later to make it robust and correct when the teacher flow is added
                          theme_color: _selectedColor,
                          hive_code: generateJoinCode(),
                        );

                        try{
                        await HiveRepository(ref).createHiveDoc(hive);
                        } catch(e) {
                          Get.snackbar("Error", "Error creating hive: $e");
                          return;
                        }
                        
                        Get.snackbar("Success", "Hive created successfully!");
                        final hiveProvider = ref.watch(hiveServiceProvider.notifier);
                        hiveProvider.updateHive(hive);

                        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //     content: Text('Creating hive: ${hiveName.text}')));

                        createHiveSuccessPopup();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _step < 2 ? const Color.fromARGB(255, 0, 0, 0) : _selectedColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _step < 2 ? const SizedBox.shrink() 
                          : const Icon(Icons.group_add_outlined,color: Colors.black, size: 25,),
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

typedef SubjectEntry = DropdownMenuEntry<SubjectLabel>;

enum SubjectLabel {
  mathematics('Mathematics'),
  science('Science'),
  history('History'),
  english('English'),
  art('Art'),
  music('Music'),
  physicalEducation('Physical Education'),
  computerScience('Computer Science'),
  foreignLanguages('Foreign Languages'),
  economics('Economics'),
  psychology('Psychology');

  const SubjectLabel(this.label);
  final String label;

  static final List<DropdownMenuEntry<SubjectLabel>> entries =
      SubjectLabel.values.map((subject) {
    return DropdownMenuEntry<SubjectLabel>(
      value: subject,
      label: subject.label,
    );
  }).toList();
}
