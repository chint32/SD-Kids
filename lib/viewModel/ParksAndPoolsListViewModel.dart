import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sd_kids/models/ParksAndPools.dart';
import '../models/FirebaseResponse.dart';
import '../repositories/FirebaseRepository.dart';

class ParksAndPoolsListViewModel extends ChangeNotifier {
  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();
  List<ParksAndPools> _parksAndPools = [];
  FirebaseResponse _firebaseResponse = FirebaseResponse.initial('Initial Data');
  FirebaseResponse get response => _firebaseResponse;

  void clearData(){
    _parksAndPools.clear();
    _firebaseResponse.data = _parksAndPools;
    notifyListeners();
  }

  Future<void> getParksAndPools() async {
    print('getEvents() called');
    _firebaseResponse = FirebaseResponse.loading('Fetching parks and pools');
    notifyListeners();
    try {
      _parksAndPools = await firebaseRepository.getParksAndPools();
      _parksAndPools.sort((a,b) => a.price.compareTo(b.price));
      print(_parksAndPools.length);
      _firebaseResponse = FirebaseResponse.completed(_parksAndPools);
      notifyListeners();
    } catch (e) {
      _firebaseResponse = FirebaseResponse.error(e.toString());
      print(e);
      notifyListeners();
    }
  }

  Future<bool> upVoteParkAndPool(ParksAndPools parkAndPool, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.upVote(parkAndPool, 'pools_splash_pads',fcmToken, isRemoval);
  }
  Future<bool> downVoteParkAndPool(ParksAndPools parkAndPool, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.downVote(parkAndPool, 'pools_splash_pads', fcmToken, isRemoval);
  }

}