import 'package:get_it/get_it.dart';
import 'package:sd_kids/repositories/FirebaseRepository.dart';
void setupLocator() {
  GetIt.instance.registerLazySingleton<FirebaseRepository>(
          () => FirebaseRepositoryImpl()
  );
}