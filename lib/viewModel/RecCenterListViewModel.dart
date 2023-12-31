import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sd_kids/models/RecCenter.dart';
import '../models/FirebaseResponse.dart';
import '../repositories/FirebaseRepository.dart';

class RecCenterListViewModel extends ChangeNotifier {
  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();
  List<RecCenter> _recCenters = [];
  FirebaseResponse _firebaseResponse = FirebaseResponse.initial('Initial Data');

  FirebaseResponse get response => _firebaseResponse;

  void clearData() {
    _recCenters.clear();
    _firebaseResponse.data = _recCenters;
    notifyListeners();
  }

  Future<void> getRecCenters() async {
    print('getRecCenters() called');
    _firebaseResponse = FirebaseResponse.loading('Fetching rec centers');
    notifyListeners();
    try {
      _recCenters = await firebaseRepository.getRecCenters();
      _recCenters.sort((a,b) => b.upVotes.length.compareTo(a.upVotes.length));
      print(_recCenters.length);
      _firebaseResponse = FirebaseResponse.completed(_recCenters);
      notifyListeners();
    } catch (e) {
      _firebaseResponse = FirebaseResponse.error(e.toString());
      print(e);
      notifyListeners();
    }
  }

  Future<bool> upVoteRecCenter(RecCenter recCenter, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.upVote(recCenter, 'rec_centers', fcmToken, isRemoval);
  }
  Future<bool> downVoteRecCenter(RecCenter recCenter, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.downVote(recCenter, 'rec_centers', fcmToken, isRemoval);
  }
}