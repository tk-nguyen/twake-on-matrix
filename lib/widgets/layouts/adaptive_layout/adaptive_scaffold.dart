import 'package:fluffychat/pages/chat_list/client_chooser_button.dart';
import 'package:fluffychat/widgets/layouts/adaptive_layout/adaptive_scaffold_view.dart';
import 'package:fluffychat/widgets/layouts/enum/adaptive_destinations_enum.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

typedef OnOpenSearchPage = Function();
typedef OnCloseSearchPage = Function();
typedef OnClientSelectedSetting = Function(Object object, BuildContext context);
typedef OnDestinationSelected = Function(int index);

class AdaptiveScaffoldApp extends StatefulWidget {
  final String? activeRoomId;

  const AdaptiveScaffoldApp({
    super.key,
    this.activeRoomId,
  });

  @override
  State<AdaptiveScaffoldApp> createState() => AdaptiveScaffoldAppController();
}

class AdaptiveScaffoldAppController extends State<AdaptiveScaffoldApp> {
  final ValueNotifier<AdaptiveDestinationEnum> activeNavigationBar =
      ValueNotifier<AdaptiveDestinationEnum>(AdaptiveDestinationEnum.rooms);

  final PageController pageController =
      PageController(initialPage: 1, keepPage: true);

  List<AdaptiveDestinationEnum> get destinations => [
        AdaptiveDestinationEnum.contacts,
        AdaptiveDestinationEnum.rooms,
        AdaptiveDestinationEnum.settings,
      ];

  void onDestinationSelected(int index) {
    final destinationType = destinations[index];
    activeNavigationBar.value = destinationType;
    pageController.jumpToPage(index);
  }

  void clientSelected(
    Object object,
    BuildContext context,
  ) async {
    if (object is SettingsAction) {
      switch (object) {
        case SettingsAction.settings:
          _onOpenSettingsPage();
          break;
        case SettingsAction.archive:
        case SettingsAction.addAccount:
        case SettingsAction.newStory:
        case SettingsAction.newSpace:
        case SettingsAction.invite:
          break;

        default:
          break;
      }
    }
  }

  void _onOpenSettingsPage() {
    activeNavigationBar.value = AdaptiveDestinationEnum.settings;
    _jumpToPageByIndex();
  }

  void _onOpenSearchPage() {
    pageController.jumpToPage(AdaptiveDestinationEnum.search.index);
  }

  void _onCloseSearchPage() {
    activeNavigationBar.value = AdaptiveDestinationEnum.rooms;
    _jumpToPageByIndex();
  }

  void _jumpToPageByIndex() {
    pageController.jumpToPage(activeNavigationBar.value.index);
  }

  MatrixState get matrix => Matrix.of(context);

  @override
  Widget build(BuildContext context) => AppScaffoldView(
        destinations: destinations,
        activeRoomId: widget.activeRoomId,
        activeNavigationBar: activeNavigationBar,
        pageController: pageController,
        onOpenSearchPage: _onOpenSearchPage,
        onCloseSearchPage: _onCloseSearchPage,
        onDestinationSelected: onDestinationSelected,
        onClientSelected: clientSelected,
      );
}
