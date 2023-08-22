import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import '../models/FirebaseResponse.dart';
import '../models/ThingToDo.dart';
import '../repositories/FirebaseRepository.dart';

class ThingsToDoListViewModel extends ChangeNotifier {
  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();
  List<String> _categories = [];
  List<ThingToDo> _thingsToDo = [];
  FirebaseResponse _firebaseResponse = FirebaseResponse.initial('Initial Data');
  FirebaseResponse get response => _firebaseResponse;

  void clearData(){
    _thingsToDo.clear();
    _firebaseResponse.data = _thingsToDo;
    notifyListeners();
  }

  Future<void> getThingsToDo() async {
    print('getThingsToDo() called');
    _firebaseResponse = FirebaseResponse.loading('Fetching things to do');
    notifyListeners();
    try {
      var data = await firebaseRepository.getThingsToDo();
      _categories = data['categories'];
      _thingsToDo = data['thingsToDo'];
      _thingsToDo.sort((a,b) => a.price.compareTo(b.price));
      print(_thingsToDo.length);
      _firebaseResponse = FirebaseResponse.completed(
          {
            'categories': _categories,
            'thingsToDo': _thingsToDo
          }
      );
      notifyListeners();
    } catch (e) {
      _firebaseResponse = FirebaseResponse.error(e.toString());
      print(e);
      notifyListeners();
    }
  }

  void filterList(List<String> categories){
    if(categories.length == 4){
      _firebaseResponse = FirebaseResponse.completed(_thingsToDo);
      notifyListeners();
      return;
    }
    List<ThingToDo> filteredList = [];
    for(var cat in categories){
      for(var event in _thingsToDo){
        if(event.categories.contains(cat)){
          filteredList.add(event);
          continue;
        }
      }
    }
    _firebaseResponse = FirebaseResponse.completed(filteredList);
    notifyListeners();
  }

}