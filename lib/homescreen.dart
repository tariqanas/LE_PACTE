import 'package:eachday/services/get_today_order.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<HomeScreen> {
  String _todayOrder = '';
  int _duration = 86400;
  final CountDownController _countDownController = CountDownController();

  @override
  void initState() {
    super.initState();

    Future<String>.delayed(
            const Duration(seconds: 2), () => 'Chargement du nouveau défi.')
        .then((String value) {
      setState(() {
        fetchOrder();
      });
    });
  }

  Future<String> fetchOrder() async {
    return _todayOrder = await const GetTodayOrderService().getTodayOrder();
  }

  Widget _proofButton({required String title, VoidCallback? onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        icon: const Icon(Icons.add_a_photo_rounded),
        onPressed: onPressed,
        label: const Text('Accepter 🔥'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _rejectButton({required String title, VoidCallback? onPressed}) {
    return Flexible(
      child: FloatingActionButton.extended(
        icon: const Icon(Icons.cancel_outlined),
        onPressed: onPressed,
        label: const Text('Refuser  🏃'),
      ),
    );
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
            Text(_todayOrder == '' ? '⌛.👹.⌛ ' : _todayOrder + ' 🔥',
                softWrap: false,
                style: const TextStyle(color: Colors.white, fontSize: 19)),
            CircularCountDownTimer(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                initialDuration: 0,
                controller: _countDownController,
                textStyle: const TextStyle(color: Colors.red, fontSize: 45),
                isReverse: true,
                isTimerTextShown: true,
                autoStart: true,
                onStart: () {
                  debugPrint('Countdown started');
                },
                onComplete: () {
                  debugPrint('YOU DIED !');
                },
                duration: _duration,
                fillColor: Colors.red,
                ringColor: Colors.redAccent),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _rejectButton(
              title: "refuse", onPressed: () => _countDownController.restart()),
          _proofButton(
              title: "proof", onPressed: () => _countDownController.pause()),
        ],
      ),
    );
  }
}
