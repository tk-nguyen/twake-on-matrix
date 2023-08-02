import 'package:fluffychat/pages/new_private_chat/search_contacts_controller.dart';
import 'package:fluffychat/widgets/twake_components/twake_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linagora_design_flutter/colors/linagora_ref_colors.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';


class SearchContactAppBar extends StatefulWidget {

  final SearchContactsController searchContactsController;
  final FocusNode? focusNode;
  final String title;
  final String? hintText;

  const SearchContactAppBar({
    super.key,
    required this.searchContactsController,
    required this.title,
    this.hintText,
    this.focusNode,
  });

  @override
  State<SearchContactAppBar> createState() => _SearchContactAppBarState();
}

class _SearchContactAppBarState extends State<SearchContactAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.15))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 1),
                blurRadius: 80,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 1),
                blurRadius: 3,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      titleSpacing: 0,
      leading: TwakeIconButton(
        icon: Icons.arrow_back,
        onPressed: () => context.pop(),
        tooltip: L10n.of(context)!.back,
        paddingAll: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: ValueListenableBuilder(
          valueListenable: widget.searchContactsController.isSearchModeNotifier,
          builder: (context, isSearchModeNotifier, child) {
            if (isSearchModeNotifier) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextField(
                  focusNode: widget.focusNode,
                  autofocus: true,
                  maxLines: 1,
                  buildCounter: (BuildContext context, {
                    required int currentLength,
                    required int? maxLength,
                    required bool isFocused,
                  }) => const SizedBox.shrink(),
                  maxLength: 200,
                  cursorHeight: 26,
                  scrollPadding: const EdgeInsets.all(0),
                  controller: widget.searchContactsController.textEditingController,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: widget.hintText, hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: LinagoraRefColors.material().neutral[60]),
                  ),
                ),
              );
            }
            return Text(widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface));
          }
        ),
      ),
      actions: [
        ValueListenableBuilder(
          valueListenable: widget.searchContactsController.isSearchModeNotifier,
          builder: (context, isSearchModeNotifier, child) {
            if (isSearchModeNotifier) {
              return TwakeIconButton(
                onPressed: () => widget.searchContactsController.onCloseSearchTapped(),
                tooltip: L10n.of(context)!.close,
                icon: Icons.close,
                paddingAll: 10.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),);
            }

            return Row(
              children: [
                TwakeIconButton(
                  icon: Icons.search,
                  onPressed: () => widget.searchContactsController.openSearchBar(),
                  tooltip: L10n.of(context)!.search,
                  paddingAll: 10.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0)),
                TwakeIconButton(
                  icon: Icons.more_vert,
                  onPressed: () {},
                  tooltip: L10n.of(context)!.more,
                  paddingAll: 10.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0)),
              ],
            );
          }
        ),
      ]);
  }
}