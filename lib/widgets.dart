import 'package:flutter/material.dart';

Widget loadingIndicator() {
  return Stack(
    children: [
      Opacity(
        opacity: 0.5,
        child: const ModalBarrier(dismissible: false, color: Colors.black),
      ),
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 10),
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(
                "Loading",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}


