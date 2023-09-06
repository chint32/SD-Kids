import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:sd_kids/models/FoodDeal.dart';
import '../models/FirebaseResponse.dart';
import '../repositories/FirebaseRepository.dart';

class FoodDealListViewModel extends ChangeNotifier{
  var firebaseRepository = GetIt.instance.get<FirebaseRepository>();
  List<FoodDeal> _foodDeals = [];
  FirebaseResponse _firebaseResponse = FirebaseResponse.initial('Initial Data');
  FirebaseResponse get response => _firebaseResponse;

  void clearData(){
    _foodDeals.clear();
    _firebaseResponse.data = _foodDeals;
    notifyListeners();
  }

  Future<void> getFoodDeals() async {
    print('getFoodDeals() called');
    _firebaseResponse = FirebaseResponse.loading('Fetching food deals');
    notifyListeners();
    try {
      _foodDeals = await firebaseRepository.getFoodDeals();
      _foodDeals.sort((a,b) => a.ageLimit.compareTo(b.ageLimit));
      print(_foodDeals.length);
      _firebaseResponse = FirebaseResponse.completed(_foodDeals);
      notifyListeners();
    } catch (e) {
      _firebaseResponse = FirebaseResponse.error(e.toString());
      print(e);
      notifyListeners();
    }
  }

  Future<bool> upVoteFoodDeal(FoodDeal foodDeal, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.upVote(foodDeal, 'food_deals',fcmToken, isRemoval);
  }
  Future<bool> downVoteFoodDeal(FoodDeal foodDeal, String fcmToken, bool isRemoval) async {
    return await firebaseRepository.downVote(foodDeal, 'food_deals', fcmToken, isRemoval);
  }
}