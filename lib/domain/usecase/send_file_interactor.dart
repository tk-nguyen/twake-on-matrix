
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluffychat/data/network/upload_file/file_info.dart';
import 'package:fluffychat/presentation/extensions/room_extension.dart';
import 'package:fluffychat/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

class SendFileInteractor {
  Future<void> execute({
    required Room room,
    required FilePickerResult filePickerResult,
    String? txId,
    Event? inReplyTo,
    String? editEventId,
    int? shrinkImageMaxDimension,
    Map<String, dynamic>? extraContent,
  }) async {
    try {
      final fileInfos = filePickerResult.files.map((xFile) => FileInfo(
        xFile.name,
        xFile.path ?? '${getTemporaryDirectory()}/${xFile.name}',
        xFile.size,
        readStream: xFile.readStream,
      )).toList();

      for (final fileInfo in fileInfos) {
        await room.sendImageFileEvent(
          fileInfo,
          msgType: MessageTypes.File,
          txid: txId,
          editEventId: editEventId,
          inReplyTo: inReplyTo,
          shrinkImageMaxDimension: shrinkImageMaxDimension,
        );
      }
    } catch(error) {
      Logs().d("SendFileInteractor: execute(): $error");
    }
  }
}