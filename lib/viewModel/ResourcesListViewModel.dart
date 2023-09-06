import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sd_kids/models/Resource.dart';
import '../models/FirebaseResponse.dart';
import '../repositories/FirebaseRepository.dart';

class ResourcesListViewModel extends ChangeNotifier {
  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();
  List<String> _types = [];
  List<Resource> _resources = [];
  FirebaseResponse _firebaseResponse = FirebaseResponse.initial('Initial Data');

  FirebaseResponse get response => _firebaseResponse;

  void clearData() {
    _resources.clear();
    _firebaseResponse.data = _resources;
    notifyListeners();
  }

  Future<void> getResources() async {
    print('getResources() called');
    _firebaseResponse = FirebaseResponse.loading('Fetching resources');
    notifyListeners();
    try {
      var data = await firebaseRepository.getResources();
      _types = data['types'];
      _resources = data['resources'];
      _resources.sort((a,b) => b.upVotes.length.compareTo(a.upVotes.length));
      _firebaseResponse = FirebaseResponse.completed(
          {
            'types': _types,
            'resources': _resources
          }
      );
      notifyListeners();
    } catch (e) {
      _firebaseResponse = FirebaseResponse.error(e.toString());
      print(e);
      notifyListeners();
    }
  }

  Future<bool> upVoteResource(Resource resource, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.upVote(resource, 'resources', fcmToken, isRemoval);
  }
  Future<bool> downVoteResource(Resource resource, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.downVote(resource, 'resources', fcmToken, isRemoval);
  }
}