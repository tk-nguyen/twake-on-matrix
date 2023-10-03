import 'package:fluffychat/config/app_config.dart';
import 'package:fluffychat/data/hive/hive_collection_tom_database.dart';
import 'package:fluffychat/di/global/get_it_initializer.dart';
import 'package:fluffychat/pages/bootstrap/bootstrap_dialog.dart';
import 'package:fluffychat/pages/connect/connect_page_mixin.dart';
import 'package:fluffychat/pages/settings_dashboard/settings_dashboard_manager.dart';
import 'package:fluffychat/presentation/enum/settings/settings_enum.dart';
import 'package:fluffychat/utils/url_launcher.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'settings_view.dart';

class Settings extends StatefulWidget {
  final Widget? bottomNavigationBar;

  const Settings({
    super.key,
    this.bottomNavigationBar,
  });

  @override
  SettingsController createState() => SettingsController();
}

class SettingsController extends State<Settings> with ConnectPageMixin {
  late SettingsDashboardManagerController settingsDashboardManagerController;

  List<SettingEnum> getListSettingItem() {
    return [
      SettingEnum.chatSettings,
      SettingEnum.privacyAndSecurity,
      SettingEnum.notificationAndSounds,
      SettingEnum.chatFolders,
      SettingEnum.appLanguage,
      SettingEnum.devices,
      SettingEnum.help,
      SettingEnum.logout,
    ];
  }

  String get mxid => settingsDashboardManagerController.mxid(context);

  String get displayName =>
      settingsDashboardManagerController.displayName(context);

  void logoutAction() async {
    final noBackup = showChatBackupBanner == true;
    if (await showOkCancelAlertDialog(
          useRootNavigator: false,
          context: context,
          title: L10n.of(context)!.areYouSureYouWantToLogout,
          message: L10n.of(context)!.noBackupWarning,
          isDestructiveAction: noBackup,
          okLabel: L10n.of(context)!.logout,
          cancelLabel: L10n.of(context)!.cancel,
        ) ==
        OkCancelResult.cancel) {
      return;
    }
    await tryLogoutSso(context);
    final hiveCollectionToMDatabase = getIt.get<HiveCollectionToMDatabase>();
    await hiveCollectionToMDatabase.clear();
    final matrix = Matrix.of(context);
    await showFutureLoadingDialog(
      context: context,
      future: () => matrix.client.logout(),
    );
  }

  Client get client => Matrix.of(context).client;

  @override
  void initState() {
    settingsDashboardManagerController =
        SettingsDashboardManagerController.instance;
    settingsDashboardManagerController.getCurrentProfile(client);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkBootstrap();
    });
    super.initState();
  }

  void checkBootstrap() async {
    if (!client.encryptionEnabled) return;
    await client.accountDataLoading;
    await client.userDeviceKeysLoading;
    if (client.prevBatch == null) {
      await client.onSync.stream.first;
    }
    final crossSigning =
        await client.encryption?.crossSigning.isCached() ?? false;
    final needsBootstrap =
        await client.encryption?.keyManager.isCached() == false ||
            client.encryption?.crossSigning.enabled == false ||
            crossSigning == false;
    final isUnknownSession = client.isUnknownSession;
    setState(() {
      showChatBackupBanner = needsBootstrap || isUnknownSession;
    });
  }

  bool? crossSigningCached;
  bool? showChatBackupBanner;

  void firstRunBootstrapAction([_]) async {
    if (showChatBackupBanner != true) {
      showOkAlertDialog(
        context: context,
        title: L10n.of(context)!.chatBackup,
        message: L10n.of(context)!.onlineKeyBackupEnabled,
        okLabel: L10n.of(context)!.close,
      );
      return;
    }
    await BootstrapDialog(
      client: Matrix.of(context).client,
    ).show(context);
    checkBootstrap();
  }

  void goToSettingsProfile(Profile? profile) async {
    settingsDashboardManagerController.optionsSelectNotifier.value =
        SettingEnum.profile;
    context.push(
      '/rooms/profile',
      extra: profile,
    );
  }

  void onClickToSettingsItem(SettingEnum settingEnum) {
    settingsDashboardManagerController.optionsSelectNotifier.value =
        settingEnum;
    switch (settingEnum) {
      case SettingEnum.chatSettings:
        context.go('/rooms/chat');
        break;
      case SettingEnum.privacyAndSecurity:
        context.go('/rooms/security');
        break;
      case SettingEnum.notificationAndSounds:
        context.go('/rooms/notifications');
        break;
      case SettingEnum.chatFolders:
        break;
      case SettingEnum.appLanguage:
        break;
      case SettingEnum.devices:
        context.go('/rooms/devices');
        break;
      case SettingEnum.help:
        UrlLauncher(
          context,
          AppConfig.supportUrl,
        ).openUrlInAppBrowser();
        break;
      case SettingEnum.logout:
        logoutAction();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsView(
      this,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}