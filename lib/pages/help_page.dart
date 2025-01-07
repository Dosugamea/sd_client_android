import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection('はじめに',
                  'このアプリはAUTOMATIC1111氏制作のstable-diffusion-webui向けのAPIクライアントです。\n\n本アプリを利用するためには、自前のパソコンまたはサーバー上で別途、stable-diffusion-webuiを稼働させる必要があります。'),
              _buildHelpSection('セットアップ',
                  '1. AUTOMATIC1111/stable-diffusion-webui を任意のパソコンまたはサーバーに導入し、起動できる状態にします。\n2. start.bat またはstart.ps1を編集し、COMMANDLINE_ARGSに"--api --api-auth (任意のユーザー名):(任意のパスワード) --share --gradio-auth (任意のユーザー名):(任意のパスワード) --port=7860" を追記します。\n3. start.bat またはstart.ps1を実行し、WebUIを起動します。\n4. コマンドラインに表示される gradio.liveで終わるURLを確認します。\n5. スマホでこのアプリの設定画面を開きます\n6. 先ほど指定したユーザー名とパスワード、およびGradioのURLを入力します\n7. 最後に接続テストを行い、接続できることを確認したら、設定を保存して完了です。\n8.(Gradioでは72時間ごとにURLの更新が必要です)'),
              _buildHelpSection('よくあるトラブル',
                  'Q. パソコン上でWebUIを立ち上げたときコマンドラインに"Could not create share link, please check your internet connection." というエラーが発生し、URLが出てきません。\nA. GradioがWindowsファイアウォールまたはウイルス対策ソフトによってブロックされている可能性があります。各種ウイルス対策ソフトの例外に追加してください。\n\nQ. どうすれば生成モデルを選択できますか?\nA. すみませんが、このクライアントではモデルを選択できません。利用したいモデルをあらかじめ、WebUIで選択してください。\n\nQ. ユーザー名とパスワードを指定せずに利用することはできますか?\nA. 指定は必須です。セキュリティ上、意図的に必須の仕様としています。'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Card(
      child: ExpansionTile(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content),
          ),
        ],
      ),
    );
  }
}
