import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_application/program.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_application/task.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter_application/theme/theme_constant.dart';
import 'package:flutter_application/theme/theme_manager.dart';

const apiKey = 'AIzaSyDbcGt9Eso8s-UViE7zIgJZEeCYCe60lMc';
const projectId = 'remindini-firebase';

ThemeManager _themeManager = ThemeManager();

void main() {
  Firestore.initialize(projectId);

  runApp(FluentApp(
    debugShowCheckedModeBanner: false,
    theme: lightTheme,
    darkTheme: darkTheme,
    themeMode: _themeManager.themeMode,
    initialRoute: "/",
    routes: {
      "/": (context) => const Home(),
    },
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentPage = 0;

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener(){
    if (mounted) {
      setState(() {
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      transitionBuilder: (child, animation) =>
          EntrancePageTransition(animation: animation, child: child),
      appBar: const NavigationAppBar(
        title: Text('NavigationView'),
      ),
      pane: NavigationPane(
        selected: _currentPage,
        displayMode: PaneDisplayMode.compact,
        onChanged: (i) => setState(() => _currentPage = i),
        items: <NavigationPaneItem>[
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text("home"),
            body: const HomePage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.fabric_folder),
            title: const Text("files"),
            body: const FilesPage(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text("settings"),
            body: const SettingsPage(),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CollectionReference tasksCollection = Firestore.instance.collection("tasks");
  CollectionReference programCollection =
      Firestore.instance.collection("programs");

  FlyoutController buttonController = FlyoutController();
  final myTitleController = TextEditingController();
  final mySubtitleController = TextEditingController();

  List<Task> listTasks = [];

  String current = "low";
  List<String> list = ["low", "high"];

  String? selectedId;

  Future<List<Document>> getTasks() async {
    List<Document> tasks = await tasksCollection.orderBy("date").get();

    return tasks;
  }

  addTask(
      String title, String subtitle, String date, List<Map> programList) async {
    await tasksCollection.add({
      "title": title,
      "subtitle": subtitle,
      "programList": programList,
      "date": date,
    });
  }

  updateTask(
      String title, String subtitle, String date, List<Map> programList) async {
    await tasksCollection.document(selectedId!).update({
      "title": title,
      "subtitle": subtitle,
      "programList": programList,
      "date": date,
    });
  }

  deleteTask() async {
    await tasksCollection.document(selectedId!).delete();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header:
          (list.isEmpty) ? const Center(child: ProgressRing()) : const Text(""),
      content: FutureBuilder<List<Document>>(
          future: getTasks(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Document>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: ProgressRing(),
              );
            }
            return (snapshot.data!.isEmpty)
                ? const Center(
                    child: Text("No Tasks!"),
                  )
                : ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: snapshot.data!
                        .map(
                          (task) => ListTile(
                            leading: IconButton(
                                icon: const Icon(FluentIcons.edit),
                                onPressed: () async {
                                  selectedId = task.id;
                                  myTitleController.text = task["title"];
                                  mySubtitleController.text = task["subtitle"];
                                  buttonController.open();
                                }),
                            title: Text(task["title"]),
                            subtitle: Text(task["subtitle"]),
                            trailing: IconButton(
                              icon: const Icon(FluentIcons.delete),
                              onPressed: () async {
                                selectedId = task.id;
                                deleteTask();
                                setState(() {});
                              },
                            ),
                            onPressed: () {
                              debugPrint(task.id);
                            },
                          ),
                        )
                        .toList(),
                  );
          }),
      bottomBar: Flyout(
          controller: buttonController,
          content: (context) {
            return FlyoutContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 400.0,
                    child: ComboBox<String>(
                      items: list
                          .map((e) => ComboBoxItem(value: e, child: Text(e)))
                          .toList(),
                      value: current,
                      onChanged: (value) {
                        setState(() {
                          current = value as String;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 400.0,
                    child: TextBox(
                      controller: myTitleController,
                      header: 'Title:',
                      placeholder: 'title',
                      expands: false,
                    ),
                  ),
                  SizedBox(
                    width: 400.0,
                    child: TextBox(
                      header: 'subtitle:',
                      placeholder: 'subtitle',
                      maxLines: 5,
                      expands: false,
                      controller: mySubtitleController,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Button(
                    onPressed: () async {
                      if (myTitleController.text != "") {
                        if (selectedId == null) {
                          addTask(myTitleController.text,
                              mySubtitleController.text, "${DateTime.now()}", [
                            {"name": "exemple.exe", "path": "./exemple.exe"}
                          ]);
                        }
                        else if (await tasksCollection
                            .document(selectedId!)
                            .exists) {
                          updateTask(myTitleController.text,
                              mySubtitleController.text, "${DateTime.now()}", [
                            {"name": "exemple.exe", "path": "./exemple.exe"}
                          ]);
                        } else {
                          addTask(myTitleController.text,
                              mySubtitleController.text, "${DateTime.now()}", [
                            {"name": "exemple.exe", "path": "./exemple.exe"}
                          ]);
                        }
                      }
                      setState(() {
                        buttonController.close();
                        myTitleController.clear();
                        mySubtitleController.clear();
                      });
                    },
                    child: const Icon(FluentIcons.check_mark),
                  )
                ],
              ),
            );
          },
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(20.0),
            child: Tooltip(
              message: 'add new task',
              child: Button(
                onPressed: buttonController.open,
                style: ButtonStyle(
                  shape: ButtonState.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0))),
                  border: ButtonState.all(BorderSide.none),
                  padding: ButtonState.all(const EdgeInsets.all(20.0)),
                  iconSize: ButtonState.all(20.0),
                ),
                child: const Icon(FluentIcons.add),
              ),
            ),
          )),
    );
  }
}

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  CollectionReference programCollection =
      Firestore.instance.collection("programs");

  List<Program> programList = [];

  String? selectedId;

  Future<List<Document>> getPrograms() async {
    List<Document> programs = await programCollection.get();

    return programs;
  }

  addProgram(String name, String path) async {
    await programCollection.add({
      "name": name,
      "path": path,
    });
  }

  deleteProgram() async {
    await programCollection.document(selectedId!).delete();
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      dialogTitle: "Pick A File/Files ",
      type: FileType.custom,
      allowedExtensions: ["exe"],
    );

    if (result == null) {
      return;
    }

    for (PlatformFile file in result.files) {
      addProgram(file.name, file.path!);
      debugPrint("File Added!");
    }

    for (Program program in programList) {
      debugPrint("program=${program.name} |path=${program.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: FutureBuilder<List<Document>>(
          future: getPrograms(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Document>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: ProgressRing(),
              );
            }
            return (snapshot.data!.isEmpty)
                ? const Center(
                    child: Text("No Programs!"),
                  )
                : ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: snapshot.data!
                        .map(
                          (task) => ListTile(
                            leading: IconButton(
                                icon: const Icon(FluentIcons.app_icon_default),
                                onPressed: () async {
                                  selectedId = task.id;
                                }),
                            title: Text(task["name"]),
                            subtitle: Text(task["path"]),
                            trailing: IconButton(
                              icon: const Icon(FluentIcons.delete),
                              onPressed: () async {
                                selectedId = task.id;
                                deleteProgram();
                                setState(() {});
                              },
                            ),
                            onPressed: () {
                              debugPrint(task.id);
                            },
                          ),
                        )
                        .toList(),
                  );
          }),
      bottomBar: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(20.0),
        child: Tooltip(
          message: 'add new program',
          child: Button(
            onPressed: () {
              _pickFile();
              setState(() {});
            },
            style: ButtonStyle(
              shape: ButtonState.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0))),
              border: ButtonState.all(BorderSide.none),
              padding: ButtonState.all(const EdgeInsets.all(20.0)),
              iconSize: ButtonState.all(20.0),
            ),
            child: const Icon(FluentIcons.add),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool checked_1 = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: const EdgeInsets.all(5.0),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ToggleSwitch(
              checked: _themeManager.themeMode == ThemeMode.dark,
              onChanged: (v) {
                setState(() {
                  _themeManager.toggleTheme(v);
                  debugPrint("Theme Changed");
                });
              },
              content: const Text("Dark Mode"),
            ),
            ToggleSwitch(
              checked: checked_1,
              onChanged: (v) => setState(() {
                checked_1 = v;
                if (checked_1) {
                  debugPrint("Concentration Mode Activated!");
                } else {
                  debugPrint("Concentration Mode Deactivated!");
                }
              }),
              content: const Text("Concentration Mode"),
            ),
          ]),
    );
  }
}
