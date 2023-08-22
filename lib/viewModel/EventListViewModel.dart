import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sd_kids/repositories/FirebaseRepository.dart';
import '../models/Event.dart';
import '../models/FirebaseResponse.dart';

class EventListViewModel with ChangeNotifier {

  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();
  List<String> _categories = [];
  List<Event> _events = [];
  FirebaseResponse _firebaseResponse = FirebaseResponse.initial('Initial Data');
  FirebaseResponse get response => _firebaseResponse;

  void clearData(){
    _events.clear();
    _firebaseResponse.data = _events;
    notifyListeners();
  }

  Future<void> getEvents() async {
    print('getEvents() called');
    _firebaseResponse = FirebaseResponse.loading('Fetching events');
    notifyListeners();
    try {
      var data = await firebaseRepository.getEvents();
      _categories = data['categories'];
      _events = data['events'];
      _events.sort((a,b) => a.startDateTime.compareTo(b.startDateTime));
      _firebaseResponse = FirebaseResponse.completed(
          {
            'categories': _categories,
            'events': _events
          }
      );
      notifyListeners();
    } catch (e) {
      _firebaseResponse = FirebaseResponse.error(e.toString());
      print(e);
      notifyListeners();
    }
  }
}