---
title: "㊗️ QWERTYを卒業します"
date: 2026-03-09T00:00:00+09:00
draft: true
tags: ["keyboard", "colemak-dh", "typing", "claude", "code"]
emoji: "⌨️"
type: "idea"
topics: ["keyboard", "colemak-dh", "typing", "claude", "code"]
published: false
canonical_url: https://aaaooai.github.io/posts/graduate-from-qwerty/
---

そろそろ卒業の季節ですね。私も卒業してみることにしました。

**QWERTY から卒業します**

長年 [QWERTY](https://ja.wikipedia.org/wiki/QWERTY%E9%85%8D%E5%88%97) 配列を使ってきましたが、[Colemak-DH](https://colemakmods.github.io/mod-dh/) に移行することにしました。

そもそもなぜ QWERTY を使っていたのかというと「通常の配列が QWERTY だから」という理由からでした。

で、今回なぜ Colemak-DH なのかというと、Claudeさん、Geminiさんに相談したら「とりあえずColemak-DHつかっとけ」と言われてしまったから。

移行してみて数日、全然うまく打てません。卒業式の練習段階と言ったところでしょうか。
以下、卒業に向けて行っていることを書いていきます。

## キー配列の変更

何はともあれ、まずはキーマップを変更します。

私は[Corne Cherry v3](https://github.com/foostan/crkbd)を使ってて、[QMK](https://github.com/qmk/qmk_firmware)でキーボード側の配列を変更しました。

https://github.com/aaaooai/qmk_firmware/blob/master/keyboards/crkbd/keymaps/mykbd-colemak-dh/keymap.c

いくらタイピングが遅くてもずっとこれでいきます。

## ひたすらタイピング

あとはひたすらタイピング。ただし、普段CLI/TUIを中心に生活している私は、英文や英単語、ローマ字を練習するよりもコマンドに慣れた方がいいと考えClaudeさんに作ってもらいました。

https://aaaooai.github.io/cmdh

## まとめ

しばらく使ってみたら続報を書きます。
