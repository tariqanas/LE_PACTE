import 'package:eachday/services/get_today_order.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  String todayOrder = '';

  @override
  void initState() {
    super.initState();

    Future<String>.delayed( const Duration(seconds: 2), () => 'Chargement du nouveau défi.')
        .then((String value) {
      setState(() {
        fetchOrder();
      });
    });
  }

  Future<String> fetchOrder() async {
    return todayOrder = await const GetTodayOrderService().getTodayOrder();
  }
  nouni() {
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Aujourd'hui, tu dois  :",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            Text(todayOrder == '' ? 'hmm...':todayOrder,
                style: TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: nouni(),
        tooltip: 'proof',
        child: const Icon(Icons.add_a_photo_rounded),
        splashColor: Colors.green,
      ),
    );
  }
}
