import 'package:dartz/dartz.dart';
import 'package:fluffychat/app_state/failure.dart';
import 'package:fluffychat/app_state/success.dart';
import 'package:fluffychat/di/global/get_it_initializer.dart';
import 'package:fluffychat/domain/app_state/contact/get_all_contacts_state.dart';
import 'package:fluffychat/domain/model/contact/contact_query.dart';
import 'package:fluffychat/domain/repository/contact_repository.dart';
import 'package:fluffychat/domain/usecase/lazy_load_interactor.dart';

class GetAllContactsInteractor with LazyLoadDataMixin {
  final ContactRepository contactRepository = getIt.get<ContactRepository>();

  GetAllContactsInteractor();

  Stream<Either<Failure, Success>> execute({
    required String keyword,
    required int limit,
  }) async* {
    try {
      // FIXME: It can break the lazy load logic
      // yield const Right(GetContactsLoading());
      final contacts = await contactRepository.fetchContact(
        query: ContactQuery(keyword: keyword),
        limit: limit,
      );
      yield Right(
        GetContactsAllSuccess(
          tomContacts: contacts,
          keyword: keyword,
        ),
      );
    } catch (e) {
      yield Left(GetContactsAllFailure(keyword: keyword, exception: e));
    }
  }
}