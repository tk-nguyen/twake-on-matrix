import 'package:dio/dio.dart';
import 'package:fluffychat/pages/chat/events/download_video_state.dart';
import 'package:fluffychat/pages/chat/events/event_video_player.dart';
import 'package:fluffychat/pages/chat/events/message_content_style.dart';
import 'package:fluffychat/presentation/mixins/handle_video_download_mixin.dart';
import 'package:fluffychat/presentation/mixins/play_video_action_mixin.dart';
import 'package:fluffychat/utils/localized_exception_extension.dart';
import 'package:fluffychat/utils/platform_infos.dart';
import 'package:fluffychat/utils/twake_snackbar.dart';
import 'package:fluffychat/widgets/mxc_image.dart';
import 'package:fluffychat/widgets/twake_components/twake_icon_button.dart';
import 'package:fluffychat/widgets/video_viewer_style.dart';
import 'package:flutter/material.dart';
import 'package:linagora_design_flutter/colors/linagora_ref_colors.dart';
import 'package:matrix/matrix.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class DownloadVideoWidget extends StatefulWidget {
  final Event event;

  const DownloadVideoWidget({super.key, required this.event});

  @override
  State<StatefulWidget> createState() => _DownloadVideoWidgetState();
}

class _DownloadVideoWidgetState extends State<DownloadVideoWidget>
    with HandleVideoDownloadMixin, PlayVideoActionMixin {
  final _downloadStateNotifier = ValueNotifier(DownloadVideoState.initial);
  String? path;
  final downloadProgressNotifier = ValueNotifier(0.0);
  final cancelToken = CancelToken();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _downloadAction();
    });
    super.initState();
  }

  @override
  void dispose() {
    cancelToken.cancel();
    downloadProgressNotifier.dispose();
    _downloadStateNotifier.dispose();
    super.dispose();
  }

  void _downloadAction() async {
    _downloadStateNotifier.value = DownloadVideoState.loading;
    try {
      path = await handleDownloadVideoEvent(
        event: widget.event,
        playVideoAction: (path) => playVideoAction(
          context,
          path,
          event: widget.event,
        ),
        progressCallback: (count, total) {
          downloadProgressNotifier.value = count / total;
        },
        cancelToken: cancelToken,
      );
      _downloadStateNotifier.value = DownloadVideoState.done;
    } on MatrixConnectionException catch (e) {
      _downloadStateNotifier.value = DownloadVideoState.failed;
      TwakeSnackBar.show(
        context,
        e.toLocalizedString(context),
      );
    } catch (e, s) {
      _downloadStateNotifier.value = DownloadVideoState.failed;
      TwakeSnackBar.show(
        context,
        e.toLocalizedString(context),
      );
      Logs().e('Error while playing video', e, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          TwakeIconButton(
            margin: VideoViewerStyle.backButtonMargin(context),
            tooltip: L10n.of(context)!.back,
            icon: Icons.close,
            onTap: () {
              cancelToken.cancel();
              Navigator.of(context).pop();
            },
            iconColor: Theme.of(context).colorScheme.surface,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              MxcImage(
                event: widget.event,
                fit: BoxFit.cover,
              ),
              Center(
                child: ValueListenableBuilder<DownloadVideoState>(
                  valueListenable: _downloadStateNotifier,
                  builder: (context, downloadState, child) {
                    switch (downloadState) {
                      case DownloadVideoState.loading:
                        return Stack(
                          children: [
                            CenterVideoButton(
                              icon: Icons.play_arrow,
                              onTap: _downloadAction,
                            ),
                            SizedBox(
                              width: MessageContentStyle.videoCenterButtonSize,
                              height: MessageContentStyle.videoCenterButtonSize,
                              child: ValueListenableBuilder(
                                valueListenable: downloadProgressNotifier,
                                builder: (context, progress, child) {
                                  return CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: LinagoraRefColors.material()
                                        .primary[100],
                                    value:
                                        PlatformInfos.isWeb ? null : progress,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      case DownloadVideoState.initial:
                        return CenterVideoButton(
                          icon: Icons.play_arrow,
                          onTap: _downloadAction,
                        );
                      case DownloadVideoState.done:
                        return CenterVideoButton(
                          icon: Icons.play_arrow,
                          onTap: () {
                            if (path != null) {
                              playVideoAction(
                                context,
                                path!,
                                event: widget.event,
                              );
                            }
                          },
                        );
                      case DownloadVideoState.failed:
                        return CenterVideoButton(
                          icon: Icons.error,
                          onTap: _downloadAction,
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}