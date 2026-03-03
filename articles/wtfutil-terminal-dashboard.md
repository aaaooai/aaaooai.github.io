---
title: "wtfutil でターミナルにダッシュボードを作る"
date: 2026-03-03T00:00:00+09:00
draft: false
tags: ["wtfutil", "terminal", "tools"]
emoji: "📟"
type: "tech"
topics: ["wtfutil", "terminal", "tools", "cli", "tui"]
published: true
canonical_url: https://aaaooai.github.io/posts/wtfutil-terminal-dashboard/
---

オレオレダッシュボードアプリは[glance](https://github.com/glanceapp/glance)がおすすめです。コンテナを起動するだけでブラウザから即アクセスできますし、コンテナが動いていれば情報もバックグラウンドで常に更新されます。スマホで見ればモバイルビューに切り替わるので、これも結構お気に入り。PWAに対応してるからスマホにインストールしておくと便利に使えます。ただ、コンピューターから見よう思うと結局ブラウザを立ち上げないといけなくて、それがちょっと面倒というか、自分の使い方に合わないなぁっと。そこでターミナルにダッシュボードを表示できる[wtfutil](https://wtfutil.com/) を使ってみます。

## wtfutil とは

wtfutil は「ターミナル用のパーソナルダッシュボード」です。時計・天気・GitHub の通知・カレンダー・Jira チケットなど、多数のモジュールをグリッドレイアウトで並べて表示できます。

## インストール

```bash
# Homebrew
brew install wtfutil

# Go
go install github.com/wtfutil/wtf@latest

# mise
mise use -g wtfutil@latest
```

mise については[こちらの記事](https://aaaooai.github.io/posts/getting-started-mise/)で解説しています。

## 起動

```bash
wtfutil
```

wtfの設定は `~/.config/wtf/config.yml` に記述します。別のパスの設定を使いたい場合は `-c` で指定できます。

```bash
wtfutil -c ~/.config/wtf/alt-config.yml
```

設定ファイルがない状態で起動するとデフォルトの画面が表示されます。

## 設定

設定ファイルは YAML で記述します。設定ファイルがない状態で起動すると、`~/.config/wtf/config.yml` にデフォルト設定が自動生成されます。デフォルト設定には clocks・feedreader・ipinfo・power・textfile・uptime の6モジュールが含まれており、複数モジュールが並ぶので `Tab` での移動なども最初から試せます。自動生成される設定はソースコードに直書きでした。気になる方は[こちら](https://github.com/wtfutil/wtf/blob/trunk/cfg/default_config_file.go)から

### グリッドレイアウト

レイアウトはグリッドで管理します。`columns` と `rows` に各列・行のサイズ（文字数）を配列で指定します。デフォルト設定では5列・6行のグリッドになっています。

```yaml
grid:
  columns: [32, 32, 32, 32, 90]  # 5列（最後の列は幅広）
  rows: [10, 10, 10, 4, 4, 90]   # 6行（最後の行は高さ大）
```

各モジュールの `position` は `top`・`left`・`height`・`width` で指定します。値はグリッドのインデックス（0始まり）です。たとえばデフォルト設定の feedreader は `top: 0, left: 2, height: 2, width: 2` で、2列目・0行目から2列×2行分を占有します。

```yaml
feedreader:
  position:
    top: 0
    left: 2
    height: 2  # 2行分
    width: 2   # 2列分
```

### キーボード操作

| キー | 操作 |
|------|------|
| `Tab` / `Shift+Tab` | モジュール間を移動 |
| `Ctrl+R` | 全モジュールをリフレッシュ |
| `Esc` | フォーカスを外す |
| `q` / `Q` | 終了 |

## わたくしが使用しているモジュールたち

私は小さい画面で表示してるので必要最低限にしています。

![ダッシュボード](https://i.imgur.com/UP4brA7.png)

設定は[こちら](https://gist.github.com/aaaooai/1bc7b6a3683bfc083f6bdd1b793899ae)

### [Feed Reader](https://wtfutil.com/modules/feedreader/)

RSS・Atom フィードを読めるモジュールです。複数のフィードをまとめて表示でき、`j`/`k` で記事を移動、`Enter` でブラウザを開けます。

Feed ReaderでGitHub Releasesを監視しています。更新は3時間毎

### [Google Calendar](https://wtfutil.com/modules/google/gcal/)

Google カレンダーの予定を表示するモジュールです。OAuth 認証が必要ですが、設定すると複数カレンダーの予定を色分けして表示できます。

使い方はwtfutilのドキュメントにあるgcalの通りで、`email:` `secretFile:` `position:`の設定だけ自分のものに変更してあります。

> Note: Setting up access to Google Calendars for Go is a bit unobvious. Check out Google's [Go Quickstart](https://developers.google.com/calendar/quickstart/go), and follow Enable The Google Calendar API.
> 
> The configuration file downloaded is the file you use for the secretFile configuration option.

ちょっとわかりづらいのでここだけ解説します。

[Go Quickstart](https://developers.google.com/calendar/quickstart/go)にアクセスします。手順が3つあるので1つずつ説明します。

1. [APIを有効にする](https://developers.google.com/workspace/calendar/api/quickstart/go?hl=ja)
   a. **APIの有効化**をクリック
   b. APIを有効にするGCPプロジェクトを選択
      以下のようなメッセージが出てくると思います。
      > プロジェクト xxxxxxxx-xxxx に変更を加えようとしています。これが目的のプロジェクトではない場合、上にあるプロジェクト セレクタを使用して別のプロジェクトを選択または作成できます。
      専用のプロジェクトを作ってもいいと思います。GCP的にはそれがおそらく正解。よくわからなければそのまま進めてしまってもOKです。
2. [OAuth 同意画面を構成する](https://developers.google.com/workspace/calendar/api/quickstart/go?hl=ja#configure_the_oauth_consent_screen)
   a. **[ブランディング] に移動**をクリック
   b. **アプリ名:** gcal    (なんでもいいです)
   c. **ユーザーサポートメール:** 自分のGmailアドレスが入力されるはず
   d. **対象** Google Workspaceを使っていれば「内部」、個人のGmailアカウントなら「外部」
   e. **連絡先情報** メールを受信できるメールアドレス
   f. **終了** 同意にチェック 
3. [デスクトップ アプリケーションの認証情報を承認する](https://developers.google.com/workspace/calendar/api/quickstart/go?hl=ja#authorize_credentials_for_a_desktop_application)
   a. **[クライアント] に移動**をクリック
   b. **[クライアントを作成]**をクリック
   c. **アプリケーションの種類:** デスクトップアプリ
   d. **名前:** なんでもOK
   e. **作成**をクリック
   作成が完了すると「OAuth クライアントを作成しました」と書かれたポップアップ画面が出てきます。そのポップアップの下の方に「JSONをダウンロード」とあるので、ここから`client_secret_xxxx.json`をダウンロードしましょう。

3でダウンロードした`client_secret_xxxx.json`を `~/.config/wtf/gcal/client_secret.json`に移動してwtfutilを起動しましょう。

初回起動時にターミナルに以下のメッセージが表示されます。

> Go to the following link in your browser then type the authorization code:
> https://accounts.google.com/o/oauth2/auth?access_type=... (press 'return' before inserting the code)

1. 表示された URL をブラウザで開き、Googleアカウントへのアクセスを許可します
2. 許可すると `http://localhost/...` へリダイレクトしようとしますが、**このリダイレクトは必ず失敗します**（正常な挙動です）
3. リダイレクト先として表示されたURLをブラウザのアドレスバーからコピーします
   ```
   http://localhost/?state=state-token&code=<ここが認証コード>&scope=...
   ```
4. `code=` の後ろにある文字列（認証コード）を取り出します
5. wtfutilのターミナル画面に戻り、**リターンキーを1回押して**入力待ち状態にしてから認証コードを貼り付けてリターンキーを押します

これでwtfutilを再起動するとGoogleカレンダーの予定がダッシュボードに表示されるでしょう。

### [Todo](https://wtfutil.com/modules/todo/)

ターミナル上で操作できる TODO リストです。タスクの追加・編集・完了がキーボードだけでできます。`#タグ` でタスクを整理することもできます。データは YAML ファイルで永続化されます。

これもドキュメント通りの使用方法です。

todoのmoduleを選択し、`N`で新しいtodoを作成、`j` `k`でアイテムを選択できます。アイテム上で`[space]`を押すと**完了** **未完了** がトグルします。

**filename**で指定したファイルは`~/.config/wtf`以下に作成されるので、複数のマシンで共有したかったらこのファイルを転送するといいでしょう。

### [URL Check](https://wtfutil.com/modules/urlcheck/)

指定した URL のステータスコードを定期的に確認するモジュールです。サービスの死活監視として使えます。タイムアウトや DNS エラーも検知します。

これはセルフホストしてるサービスなどの監視に使ってます。

## まとめ

- YAML で設定を書くだけでターミナルにダッシュボードが作れる
- グリッドレイアウトで自由に配置できる
- モジュールが豊富でRSS・カレンダー・死活監視など多数対応
- mise で管理すればバージョンも固定できる
