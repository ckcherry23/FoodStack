import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodstack/src/services/firestoreOrders.dart';
import 'package:foodstack/src/services/firestoreUsers.dart';
import 'package:foodstack/src/utilities/statusEnums.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:uuid/uuid.dart';
import 'package:foodstack/src/models/order.dart';

class OrderProvider with ChangeNotifier {
  final firestoreService = FirestoreOrders();
  FirestoreUsers firestoreUser = FirestoreUsers();

  String _orderId;
  String _restaurantId;
  String _creatorId;
  String _paymentId;
  String _status;
  String _deliveryAddress;
  Object _coordinates;
  Timestamp _orderTime;
  double _totalPrice;
  List _cartId;

  var uuid = Uuid();

  // Getters
  String get orderId => _orderId;
  String get restaurantId => _restaurantId;
  String get creatorId => _creatorId;
  String get paymentId => _paymentId;
  String get status => _status;
  String get deliveryAddress => _deliveryAddress;
  Timestamp get orderTime => _orderTime;
  double get totalPrice => _totalPrice;
  List get cartId => _cartId;

  Stream<List<DocumentSnapshot>> getNearbyOrdersList(
          GeoFirePoint center, double radius) =>
      firestoreService.getNearbyOrders(center, radius);

  // Functions
  setOrder(Order order, int joinDurationMins, String newCartId) {
    int noOfSecondsPerMinute = 60;
    _orderId = uuid.v4();
    _restaurantId = order.restaurantId;
    _creatorId = FirebaseAuth.instance.currentUser.uid;
    _paymentId = null;
    _status = Status.active.toString();
    _deliveryAddress = order.deliveryAddress;
    _coordinates = order.coordinates;
    _totalPrice = order.totalPrice;

    Timestamp currentTime = Timestamp.now();
    int seconds = currentTime.seconds + (joinDurationMins * noOfSecondsPerMinute);
    int nanoseconds = currentTime.nanoseconds;
    Timestamp orderCompletionTime = Timestamp(seconds, nanoseconds);
    _orderTime = orderCompletionTime;
    print(_orderTime);

    var newOrder = Order(
        orderId: _orderId,
        restaurantId: _restaurantId,
        creatorId: _creatorId,
        paymentId: _paymentId,
        status: _status,
        deliveryAddress: _deliveryAddress,
        coordinates: _coordinates,
        orderTime: _orderTime,
        totalPrice: _totalPrice,);

    firestoreService.addToCart(newCartId, _orderId);
    return firestoreService
        .addOrder(newOrder)
        .then((value) => print('Order Saved'))
        .catchError((error) => print(error));
  }

  removeOrder(String orderId) {
    firestoreService.removeOrder(orderId);
  }
}
