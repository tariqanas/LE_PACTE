import 'package:flutter/services.dart';
import "dart:math";

class GetTodayOrderService {
  const GetTodayOrderService();

  getTodayOrder() async {
    
    final _random = Random();
    String text = await rootBundle.loadString('assets/quotes/quotes.txt');
    List<String> ordersList = text.split("///");
    return ordersList[_random.nextInt(ordersList.length-1)];
  }
}
