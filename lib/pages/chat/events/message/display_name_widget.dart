import 'package:fluffychat/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class DisplayNameWidget extends StatelessWidget {
  const DisplayNameWidget({
    super.key,
    required this.event,
  });

  final Event event;

  static const int maxCharactersDisplayNameBubble = 68;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: event.fetchSenderUser(),
      builder: (context, snapshot) {
        final displayName = snapshot.data?.calcDisplayname() ??
            event.senderFromMemoryOrFallback.calcDisplayname();
        return Padding(
          padding: EdgeInsets.only(
            left: event.messageType == MessageTypes.Image ? 0 : 8.0,
            bottom: 4.0,
          ),
          child: Text(
            displayName.shortenDisplayName(
              maxCharacters: maxCharactersDisplayNameBubble,
            ),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary,
                ),
            maxLines: 2,
            overflow: TextOverflow.clip,
          ),
        );
      },
    );
  }
}
