import 'package:fluffychat/di/global/get_it_initializer.dart';
import 'package:fluffychat/pages/settings_dashboard/settings_profile/settings_profile.dart';
import 'package:fluffychat/pages/settings_dashboard/settings_profile/settings_profile_item.dart';
import 'package:fluffychat/pages/settings_dashboard/settings_profile/settings_profile_view_mobile.dart';
import 'package:fluffychat/pages/settings_dashboard/settings_profile/settings_profile_view_web.dart';
import 'package:fluffychat/presentation/model/settings/settings_profile_presentation.dart';
import 'package:fluffychat/utils/responsive/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class SettingsProfileView extends StatelessWidget {
  final SettingsProfileController controller;

  static const ValueKey settingsProfileViewMobileKey =
      ValueKey('settingsProfileViewMobile');

  static const ValueKey settingsProfileViewWebKey =
      ValueKey('settingsProfileViewWeb');

  const SettingsProfileView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = getIt.get<ResponsiveUtils>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          L10n.of(context)!.profile,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: controller.isEditedProfileNotifier,
            builder: (context, edited, _) {
              if (!edited) return const SizedBox();
              return InkWell(
                borderRadius: BorderRadius.circular(
                  20,
                ),
                onTap: () => controller.setDisplayNameAction(),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  child: Text(
                    L10n.of(context)!.done,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      backgroundColor: responsive.isWebDesktop(context)
          ? Theme.of(context).colorScheme.surface
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        child: SlotLayout(
          config: <Breakpoint, SlotLayoutConfig>{
            const WidthPlatformBreakpoint(
              end: ResponsiveUtils.minDesktopWidth,
            ): SlotLayout.from(
              key: settingsProfileViewMobileKey,
              builder: (_) {
                return SettingsProfileViewMobile(
                  profileNotifier: controller
                      .settingsDashboardManagerController.profileNotifier,
                  onAvatarTap: () => controller.setAvatarAction(),
                  settingsProfileOptions: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SettingsProfileItemBuilder(
                        settingsProfileEnum:
                            controller.getListProfileMobile[index],
                        title: controller.getListProfileMobile[index]
                            .getTitle(context),
                        settingsProfilePresentation:
                            SettingsProfilePresentation(
                          settingsProfileType: controller
                              .getListProfileMobile[index]
                              .getSettingsProfileType(),
                        ),
                        suffixIcon: controller.getListProfileMobile[index]
                            .getTrailingIcon(),
                        leadingIcon: controller.getListProfileMobile[index]
                            .getLeadingIcon(),
                        focusNode: controller.getFocusNode(
                          controller.getListProfileMobile[index],
                        ),
                        textEditingController: controller.getController(
                          controller.getListProfileMobile[index],
                        ),
                        onChange: (_, settingsProfileEnum) {
                          controller
                              .handleTextEditOnChange(settingsProfileEnum);
                        },
                        onCopyAction: () => controller.copyEventsAction(
                          controller.getListProfileMobile[index],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    itemCount: controller.getListProfileMobile.length,
                  ),
                );
              },
            ),
            const WidthPlatformBreakpoint(
              begin: ResponsiveUtils.minDesktopWidth,
            ): SlotLayout.from(
              key: settingsProfileViewWebKey,
              builder: (_) {
                return SettingsProfileViewWeb(
                  profileNotifier: controller
                      .settingsDashboardManagerController.profileNotifier,
                  basicInfoWidget: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SettingsProfileItemBuilder(
                        settingsProfileEnum:
                            controller.getListProfileBasicInfo[index],
                        title: controller.getListProfileBasicInfo[index]
                            .getTitle(context),
                        settingsProfilePresentation:
                            SettingsProfilePresentation(
                          settingsProfileType: controller
                              .getListProfileBasicInfo[index]
                              .getSettingsProfileType(),
                        ),
                        suffixIcon: controller.getListProfileBasicInfo[index]
                            .getTrailingIcon(),
                        focusNode: controller.getFocusNode(
                          controller.getListProfileBasicInfo[index],
                        ),
                        textEditingController: controller.getController(
                          controller.getListProfileBasicInfo[index],
                        ),
                        onChange: (_, settingsProfileEnum) {
                          controller
                              .handleTextEditOnChange(settingsProfileEnum);
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    itemCount: controller.getListProfileBasicInfo.length,
                  ),
                  workIdentitiesInfoWidget: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SettingsProfileItemBuilder(
                        settingsProfileEnum:
                            controller.getListProfileWorkIdentitiesInfo[index],
                        title: controller
                            .getListProfileWorkIdentitiesInfo[index]
                            .getTitle(context),
                        settingsProfilePresentation:
                            SettingsProfilePresentation(
                          settingsProfileType: controller
                              .getListProfileWorkIdentitiesInfo[index]
                              .getSettingsProfileType(),
                        ),
                        suffixIcon: controller
                            .getListProfileWorkIdentitiesInfo[index]
                            .getTrailingIcon(),
                        focusNode: controller.getFocusNode(
                          controller.getListProfileWorkIdentitiesInfo[index],
                        ),
                        textEditingController: controller.getController(
                          controller.getListProfileWorkIdentitiesInfo[index],
                        ),
                        onChange: (_, settingsProfileEnum) {
                          controller
                              .handleTextEditOnChange(settingsProfileEnum);
                        },
                        onCopyAction: () => controller.copyEventsAction(
                          controller.getListProfileWorkIdentitiesInfo[index],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 16);
                    },
                    itemCount: controller.getListProfileBasicInfo.length,
                  ),
                  onAvatarTap: () => controller.setAvatarAction(),
                );
              },
            ),
          },
        ),
      ),
    );
  }
}
