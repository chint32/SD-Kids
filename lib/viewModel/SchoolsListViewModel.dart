import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sd_kids/models/School.dart';
import '../models/FirebaseResponse.dart';
import '../repositories/FirebaseRepository.dart';

class SchoolsListViewModel extends ChangeNotifier {
  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();
  List<String> _types = [];
  List<School> _schools = [];
  FirebaseResponse _firebaseResponse = FirebaseResponse.initial('Initial Data');

  FirebaseResponse get response => _firebaseResponse;

  void clearData() {
    _schools.clear();
    _firebaseResponse.data = _schools;
    notifyListeners();
  }

  Future<void> getSchools() async {
    print('getSchools() called');
    _firebaseResponse = FirebaseResponse.loading('Fetching schools');
    notifyListeners();
    try {
      var data = await firebaseRepository.getSchools();
      _types = data['types'];
      _schools = data['schools'];
      _schools.sort((a,b) => b.upVotes.length.compareTo(a.upVotes.length));
      print(_schools.length);
      _firebaseResponse = FirebaseResponse.completed(
        {
          'types': _types,
          'schools': _schools
        }
      );
      notifyListeners();
    } catch (e) {
      _firebaseResponse = FirebaseResponse.error(e.toString());
      print(e);
      notifyListeners();
    }
  }

  Future<bool> upVoteSchool(School school, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.upVote(school, 'schools', fcmToken, isRemoval);
  }
  Future<bool> downVoteSchool(School school, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.downVote(school, 'resources', fcmToken, isRemoval);
  }
}