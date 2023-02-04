import 'package:flutter/material.dart';

// class MatchCounter2 extends StatelessWidget {
//   final String labelText;

//   final Function increment;
//   final Function decrement;

//   const MatchCounter(
//       {super.key,
//       required this.labelText,
//       required this.increment,
//       required this.decrement});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ElevatedButton(
//             onPressed: () => decrement(), child: const Icon(Icons.exposure_minus_1)),
//         Text(labelText),
//         ElevatedButton(
//             onPressed: () =>increment(), child: const Icon(Icons.exposure_plus_1)),
//       ],
//     );
//   }
// }

class MatchCounter extends StatefulWidget {
  // final String labelText;

  // final Function increment;
  // final Function decrement;

  final double padding;

  int counter;

  MatchCounter({
    super.key,
    // required this.labelText,
    // required this.increment,
    // required this.decrement,
    required this.counter,
    this.padding = 20,
  });

  @override
  State<MatchCounter> createState() => _MatchCounterState();
}

class _MatchCounterState extends State<MatchCounter> {
  void increment() {
    setState(() {
      widget.counter += 1;
    });
  }

  void decrement() {
    setState(() {
      if (widget.counter > 0) {
        widget.counter -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(widget.padding),
          child: ElevatedButton(
              onPressed: decrement, child: const Icon(Icons.exposure_minus_1)),
        ),
        Text(widget.counter.toString()),
        Padding(
            padding: EdgeInsets.all(widget.padding),
            child: ElevatedButton(
                onPressed: increment,
                child: const Icon(Icons.exposure_plus_1))),
      ],
    );
  }
}
