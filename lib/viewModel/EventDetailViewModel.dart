import 'package:get_it/get_it.dart';
import 'package:sd_kids/repositories/FirebaseRepository.dart';
import '../models/Event.dart';

class EventDetailViewModel {

  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();

  // Future<Event> updateEventPlanToGo(Event event, String token) async {
  //   return await firebaseRepository.updatePlanToGo(event, token);
  // }
}