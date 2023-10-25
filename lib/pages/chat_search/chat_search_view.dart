import 'dart:io';

import 'package:fluffychat/app_state/success.dart';
import 'package:fluffychat/domain/app_state/room/timeline_search_event_state.dart';
import 'package:fluffychat/pages/chat/chat_view_style.dart';
import 'package:fluffychat/pages/chat/events/message_download_content.dart';
import 'package:fluffychat/pages/chat_list/chat_list_header_style.dart';
import 'package:fluffychat/pages/chat_search/chat_search.dart';
import 'package:fluffychat/pages/chat_search/chat_search_style.dart';
import 'package:fluffychat/presentation/same_type_events_builder/same_type_events_builder.dart';
import 'package:fluffychat/utils/date_time_extension.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:fluffychat/utils/string_extension.dart';
import 'package:fluffychat/widgets/avatar/avatar.dart';
import 'package:fluffychat/widgets/highlight_text.dart';
import 'package:fluffychat/widgets/matrix.dart';
import 'package:fluffychat/widgets/twake_components/twake_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:matrix/matrix.dart';

class ChatSearchView extends StatelessWidget {
  final ChatSearchController controller;

  const ChatSearchView(
    this.controller, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          controller.onBack();
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: ChatViewStyle.toolbarHeight(context),
          automaticallyImplyLeading: false,
          title: _ChatSearchAppBar(controller),
        ),
        body: controller.eventsController == null
            ? null
            : SameTypeEventsBuilder(
                controller: controller.eventsController!,
                scrollController: controller.scrollController,
                builder: (context, eventsState, child) {
                  final success = eventsState
                      .getSuccessOrNull<TimelineSearchEventSuccess>();
                  final events = success?.events ?? [];
                  return SliverList.separated(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _SearchItem(
                        event: event,
                        searchWord: controller.debouncer.value,
                        onTap: controller.onEventTap,
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  );
                },
              ),
      ),
    );
  }
}

class _SearchItem extends StatelessWidget {
  final Event event;
  final String searchWord;
  final void Function(Event) onTap;

  const _SearchItem({
    required this.event,
    required this.searchWord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: event.fetchSenderUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? event.senderFromMemoryOrFallback;
        return InkWell(
          onTap: () => onTap(event),
          child: Padding(
            padding: ChatSearchStyle.itemPadding,
            child: Row(
              children: [
                Padding(
                  padding: ChatSearchStyle.avatarPadding,
                  child: Avatar(
                    mxContent: user.avatarUrl,
                    name: user.calcDisplayname(),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.id == Matrix.of(context).client.userID
                                  ? L10n.of(context)!.you
                                  : user.calcDisplayname(),
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color:
                                        LinagoraSysColors.material().onSurface,
                                  ),
                            ),
                          ),
                          Text(
                            event.originServerTs.localizedTimeShort(context),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: LinagoraSysColors.material().onSurface,
                                ),
                          ),
                        ],
                      ),
                      _MessageContent(event: event, searchWord: searchWord),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageContent extends StatelessWidget {
  static const _prefixLengthHighlight = 20;

  const _MessageContent({
    required this.event,
    required this.searchWord,
  });

  final Event event;
  final String searchWord;

  @override
  Widget build(BuildContext context) {
    switch (event.messageType) {
      case MessageTypes.File:
        return MessageDownloadContent(event, highlightText: searchWord);
      default:
        return HighlightText(
          text: event
              .calcLocalizedBodyFallback(
                MatrixLocals(L10n.of(context)!),
                hideReply: true,
                hideEdit: true,
                plaintextBody: true,
                removeMarkdown: true,
              )
              .substringToHighlight(
                searchWord,
                prefixLength: _prefixLengthHighlight,
              ),
          searchWord: searchWord,
          maxLines: 2,
          style: LinagoraTextStyle.material()
              .bodyMedium3
              .copyWith(color: LinagoraSysColors.material().onSurface),
        );
    }
  }
}

class _ChatSearchAppBar extends StatelessWidget {
  const _ChatSearchAppBar(
    this.controller,
  );

  final ChatSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: ChatViewStyle.paddingLeading(context),
          child: TwakeIconButton(
            icon: Icons.arrow_back,
            onTap: controller.onBack,
            tooltip: L10n.of(context)!.back,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              ChatListHeaderStyle.searchRadiusBorder,
            ),
            child: Padding(
              padding: ChatSearchStyle.inputPadding,
              child: TextField(
                controller: controller.textEditingController,
                focusNode: controller.inputFocus,
                textInputAction: TextInputAction.search,
                autofocus: true,
                decoration:
                    ChatListHeaderStyle.searchInputDecoration(context).copyWith(
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: controller.textEditingController,
                    builder: (context, value, child) => value.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              controller.textEditingController.clear();
                            },
                            icon: const Icon(Icons.close),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
