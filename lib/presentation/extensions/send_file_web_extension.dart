import 'package:matrix/matrix.dart';

extension SendFileWebExtension on Room {
  static const maxImagesCacheInRoom = 10;

  Future<String?> sendFileOnWebEvent(
    MatrixFile file, {
    SyncUpdate? fakeImageEvent,
    String? txid,
    Event? inReplyTo,
    String? editEventId,
    int? shrinkImageMaxDimension,
    Map<String, dynamic>? extraContent,
  }) async {
    txid ??= client.generateUniqueTransactionId();
    fakeImageEvent ??= await sendFakeImageEvent(
      file,
      txid: txid,
      inReplyTo: inReplyTo,
      editEventId: editEventId,
      shrinkImageMaxDimension: shrinkImageMaxDimension,
      extraContent: extraContent,
    );
    // Check media config of the server before sending the file. Stop if the
    // Media config is unreachable or the file is bigger than the given maxsize.
    try {
      final mediaConfig = await client.getConfig();
      final maxMediaSize = mediaConfig.mUploadSize;
      Logs().d(
        'SendImage::sendImageFileEvent(): FileSized ${file.size} || maxMediaSize $maxMediaSize',
      );
      if (maxMediaSize != null && maxMediaSize < file.size) {
        throw FileTooBigMatrixException(file.size, maxMediaSize);
      }
    } catch (e) {
      Logs().d('Config error while sending file', e);
      fakeImageEvent.rooms!.join!.values.first.timeline!.events!.first
          .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
      await handleImageFakeSync(fakeImageEvent);
      rethrow;
    }

    EncryptedFile? encryptedFile;
    MatrixFile? uploadFile;
    if (encrypted && client.fileEncryptionEnabled) {
      fakeImageEvent.rooms!.join!.values.first.timeline!.events!.first
          .unsigned![fileSendingStatusKey] = FileSendingStatus.encrypting.name;
      await handleImageFakeSync(fakeImageEvent);
      encryptedFile = await file.encrypt();
      uploadFile =
          MatrixFile.fromMimeType(bytes: encryptedFile!.data, name: 'crypt');
    }
    Uri? uploadResp;

    fakeImageEvent.rooms!.join!.values.first.timeline!.events!.first
        .unsigned![fileSendingStatusKey] = FileSendingStatus.uploading.name;
    while (
        uploadResp == null && uploadFile != null && uploadFile.bytes != null) {
      try {
        uploadResp = await client.uploadContent(
          uploadFile.bytes!,
          filename: uploadFile.name,
          contentType: uploadFile.mimeType,
        );
      } on MatrixException catch (e) {
        fakeImageEvent.rooms!.join!.values.first.timeline!.events!.first
            .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
        await handleImageFakeSync(fakeImageEvent);
        Logs().v('Error: $e');
        rethrow;
      } catch (e) {
        fakeImageEvent.rooms!.join!.values.first.timeline!.events!.first
            .unsigned![messageSendingStatusKey] = EventStatus.error.intValue;
        await handleImageFakeSync(fakeImageEvent);
        Logs().v('Error: $e');
        Logs().v('Send File into room failed. Try again...');
        return null;
      }
    }

    // Send event
    final content = <String, dynamic>{
      'msgtype': file.msgType,
      'body': file.name,
      'filename': file.name,
      if (encryptedFile == null) 'url': uploadResp.toString(),
      if (encryptedFile != null)
        'file': {
          'url': uploadResp.toString(),
          'mimetype': file.mimeType,
          'v': 'v2',
          'key': {
            'alg': 'A256CTR',
            'ext': true,
            'k': encryptedFile.k,
            'key_ops': ['encrypt', 'decrypt'],
            'kty': 'oct'
          },
          'iv': encryptedFile.iv,
          'hashes': {'sha256': encryptedFile.sha256}
        },
      'info': {
        ...file.info,
      },
      if (extraContent != null) ...extraContent,
    };
    final eventId = await sendEvent(
      content,
      txid: txid,
      inReplyTo: inReplyTo,
      editEventId: editEventId,
    );
    return eventId;
  }

  Future<SyncUpdate> sendFakeImageEvent(
    MatrixFile file, {
    required String txid,
    Event? inReplyTo,
    String? editEventId,
    int? shrinkImageMaxDimension,
    Map<String, dynamic>? extraContent,
  }) async {
    sendingFilePlaceholders[txid] = file;
    // sendingFileThumbnails[txid] =  MatrixImageFile(bytes: file.bytes, name: file.name);

    // Create a fake Event object as a placeholder for the uploading file:
    final fakeImageEventEvent = SyncUpdate(
      nextBatch: '',
      rooms: RoomsUpdate(
        join: {
          id: JoinedRoomUpdate(
            timeline: TimelineUpdate(
              events: [
                MatrixEvent(
                  content: {
                    'msgtype': file.msgType,
                    'body': file.name,
                    'filename': file.name,
                  },
                  type: EventTypes.Message,
                  eventId: txid,
                  senderId: client.userID!,
                  originServerTs: DateTime.now(),
                  unsigned: {
                    messageSendingStatusKey: EventStatus.sending.intValue,
                    'transaction_id': txid,
                    if (inReplyTo?.eventId != null)
                      'in_reply_to': inReplyTo?.eventId,
                    if (editEventId != null) 'edit_event_id': editEventId,
                    if (shrinkImageMaxDimension != null)
                      'shrink_image_max_dimension': shrinkImageMaxDimension,
                    if (extraContent != null) 'extra_content': extraContent,
                  },
                ),
              ],
            ),
          ),
        },
      ),
    );
    await handleImageFakeSync(fakeImageEventEvent);
    return fakeImageEventEvent;
  }

  Future<void> handleImageFakeSync(
    SyncUpdate fakeImageEvent, {
    Direction? direction,
  }) async {
    if (client.database != null) {
      await client.database?.transaction(() async {
        await client.handleSync(fakeImageEvent, direction: direction);
      });
    } else {
      await client.handleSync(fakeImageEvent, direction: direction);
    }
  }
}