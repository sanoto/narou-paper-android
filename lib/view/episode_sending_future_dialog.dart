import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:narou_paper/model/db.dart';
import 'package:narou_paper/view_model/send_episode.dart';

class EpisodeSendingFutureDialog extends StatelessWidget {
  final Episode episode;

  EpisodeSendingFutureDialog(this.episode);

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: sendEpisodeToPaper(episode),
        builder: (context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else if (snapshot.error != null)
            return _ErrorDialog(snapshot.error);
          else if (snapshot.data != null && snapshot.data.statusCode == 200)
            return _FinishedDialog(snapshot.data.body);
          else
            return _ErrorDialog(
              (snapshot.data != null)
                  ? {
                      'status code': snapshot.data.statusCode,
                      'body': (snapshot.data.body.length > 100)
                          ? snapshot.data.body.substring(0, 100)
                          : snapshot.data.body,
                    }
                  : {'error': 'タイムアウトしました'},
            );
        },
      );
}

class _FinishedDialog extends StatelessWidget {
  final String responseBody;

  const _FinishedDialog(this.responseBody);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('送信完了'),
        content: Column(
          children: <Widget>[
            Text('電子ペーパーに転送しました'),
            Text(
              responseBody,
              style: TextStyle(color: Colors.lightGreen),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}

class _ErrorDialog extends StatelessWidget {
  final Object error;

  _ErrorDialog(this.error);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('エラー'),
        content: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('データ転送時にエラーが発生しました'),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
