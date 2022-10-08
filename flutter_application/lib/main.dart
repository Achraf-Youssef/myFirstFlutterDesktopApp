import 'package:fluent_ui/fluent_ui.dart';

void main() {
  runApp(FluentApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.light, accentColor: Colors.blue),
    darkTheme: ThemeData(brightness: Brightness.dark, accentColor: Colors.blue),
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
  FlyoutController buttonController = FlyoutController();
  String current = "item 1";
  List<String> list = ["item 1", "item 2", "item 3", "item 4"];
  List<Map<String, String>> list_1 = [
    {"title":"title1", "subtitle":"subtitle1"},
    ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: (list.isEmpty)? const Center(child: ProgressRing()) : const Text("") ,
      content: ListView(children: [
        ListTile(
          leading: const Icon(FluentIcons.emoji2),
          title: Text(list_1[0]["title"]!),
          subtitle: Text(list_1[0]["subtitle"]!),
          trailing: Text("${DateTime.now()}"),
          onPressed: (() {}),
        ),
      ]),
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
                  const SizedBox(
                    width: 400.0,
                    child: TextBox(
                      header: 'Title:',
                      placeholder: 'title',
                      expands: false,
                    ),
                  ),
                  const SizedBox(
                    width: 400.0,
                    child: TextBox(
                      header: 'subtitle:',
                      placeholder: 'subtitle',
                      maxLines: 5,
                      expands: false,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Button(
                    onPressed: buttonController.close,
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
  List<String> list = [
    "item 1",
    "item 0",
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: ListView(
        children: [
          ListTile(
            title: Text(list[0]),
          ),
          ListTile(
            title: Text(list[1]),
          ),
        ],
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
  bool checked = false;
  bool checked_1 = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      padding: const EdgeInsets.all(5.0),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ToggleSwitch(
              checked: checked,
              onChanged: (v) => setState(() {
                checked = v;
                theme.toggleSwitchTheme;
                debugPrint("Theme Changed!");
              }),
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