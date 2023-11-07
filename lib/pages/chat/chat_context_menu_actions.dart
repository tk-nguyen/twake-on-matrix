import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

enum ChatContextMenuActions {
  select,
  copyMessage,
  pinMessage,
  forward,
  downloadFile;

  String getTitle(
    BuildContext context, {
    bool unpin = false,
  }) {
    switch (this) {
      case ChatContextMenuActions.select:
        return L10n.of(context)!.select;
      case ChatContextMenuActions.copyMessage:
        return L10n.of(context)!.copyMessageText;
      case ChatContextMenuActions.pinMessage:
        return unpin
            ? L10n.of(context)!.unpinThisMessage
            : L10n.of(context)!.pinMessage;
      case ChatContextMenuActions.forward:
        return L10n.of(context)!.forward;
      case ChatContextMenuActions.downloadFile:
        return L10n.of(context)!.download;
    }
  }

  IconData getIcon({
    bool unpin = false,
  }) {
    switch (this) {
      case ChatContextMenuActions.select:
        return Icons.check_circle_outline;
      case ChatContextMenuActions.copyMessage:
        return Icons.content_copy;
      case ChatContextMenuActions.pinMessage:
        return unpin ? Icons.push_pin_outlined : Icons.push_pin;
      case ChatContextMenuActions.forward:
        return Icons.shortcut;
      case ChatContextMenuActions.downloadFile:
        return Icons.download;
    }
  }
}
