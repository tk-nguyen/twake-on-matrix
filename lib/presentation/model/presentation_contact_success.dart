import 'package:fluffychat/app_state/success.dart';
import 'package:fluffychat/presentation/model/get_presentation_contacts_success.dart';
import 'package:fluffychat/presentation/model/presentation_contact.dart';

typedef PresentationContactsSuccess
    = GetPresentationContactsSuccess<PresentationContact>;

class PresentationExternalContactSuccess extends Success {
  final PresentationContact contact;

  const PresentationExternalContactSuccess({
    required this.contact,
  });

  @override
  List<Object?> get props => [contact];
}
