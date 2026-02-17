enum NavigationPage {
  home,
  tracking,
  hives,
  classroom,
  calendar,
  notifications,
  summary,
  settings,
  profile,
  addTasks,
  createHive,
  specificHive, //This is for when the user clicks on a specific hive from the hives page.
  trade,
}

extension NavigationPageExtension on NavigationPage {
  String get title {
    switch (this) {
      case NavigationPage.home:
        return 'Home';
      case NavigationPage.tracking:
        return 'Tracking';
      case NavigationPage.hives:
        return 'Hives';
      case NavigationPage.classroom:
        return 'Classroom';
      case NavigationPage.calendar:
        return 'Calendar';
      case NavigationPage.notifications:
        return 'Notifications';
      case NavigationPage.summary:
        return 'Summary';
      case NavigationPage.settings:
        return 'Settings';
      case NavigationPage.profile:
        return 'Profile';
      case NavigationPage.addTasks:
        return 'Add Tasks';
      case NavigationPage.createHive:
        return 'Create Hive';
      case NavigationPage.specificHive:
        return 'Hive Name'; //This should vary based on the hive that the user is on.
      case NavigationPage.trade:
        return 'Trade Tasks';
      //default:
        //return '';
    }
  }

  int get mainTabIndex {
    switch (this) {
      case NavigationPage.home:
        return 0;
      case NavigationPage.tracking:
        return 1;
      case NavigationPage.hives:
        return 2;
      case NavigationPage.classroom:
        return 3;
      case NavigationPage.calendar:
        return 4;
      default:
        return -1;
    }
  }

  bool get isMainPage {
    return mainTabIndex != -1;
  }
}
