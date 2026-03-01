---
title: "GitHub Pages+HugoとZennの記事を1つのリポジトリで管理する"
date: 2026-03-01T00:00:00+09:00
draft: true
tags: ["hugo", "zenn", "github-actions"]
zenn_emoji: "📝"
zenn_type: "tech"
zenn_topics: ["hugo", "zenn", "githubactions"]
zenn_published: false
---

このブログは GitHub Pages+Hugo で公開してるんですが、御上から「Zennにもクロスポストせよ」との掲示があったので対応していきます。

## 構成

```
.
├── content/
│   └── posts/          # Hugo の記事（ここに書く）
├── articles/           # Zenn の記事（自動生成）
├── scripts/
│   └── sync-zenn.awk   # 変換スクリプト
└── .github/
    └── workflows/
        └── hugo.yaml   # GitHub Actions
```

`content/posts/` に記事を書いてPushすると、GitHub Actions が自動で `articles/` に変換・コピーしてくれます。Zenn は GitHub リポジトリと連携することで `articles/` の内容を記事として認識します。

具体的な構成は https://github.com/aaaooai/aaaooai.github.io を見てください。そこにこれまでの記事もWorkflowも置いてあります。

## フロントマターの設計

Hugo と Zenn はフロントマターの形式が異なります。Hugo 向けのフィールドはそのまま、Zenn 向けのフィールドは `zenn_` プレフィックスを付けて書きます。

```yaml
---
title: "記事タイトル"
date: 2026-03-01T00:00:00+09:00
draft: false
tags: ["hugo", "zenn"]
zenn_emoji: "📝"
zenn_type: "tech"
zenn_topics: ["hugo", "zenn"]
zenn_published: true
---
```

Hugoは自分が解釈できないフィールドは無視するので、`emoji:`とかはそのままでも問題ないんですが、`published:`こいつだけはイケてなくて、`published` は Hugo v0.135.0 以降で `publishDate` の非公式エイリアスとして扱われます（[#12898](https://github.com/gohugoio/hugo/issues/12898)）。一方でZennは公開するかどうかのフラグとして解釈します。つまり、Zenn用にブーリアンを設定するとHugoが `publishDate` に日付以外の値が来たと怒ってしまうわけですね。面倒なのでZennに設定したいフィールドには`zenn_`プレフィックスを付けることにしました。

## 変換スクリプト（AWK）

`scripts/sync-zenn.awk` が変換を担っています。

```awk
BEGIN {
    c = 0
}

c == 0 && /^---$/ {
    slug = FILENAME
    gsub(/.*\//, "", slug)
    gsub(/\.md$/, "", slug)
    outfile = "articles/" slug ".md"
    c=1
    print > outfile
    next
}

c == 1 && /^---$/ {
    print "canonical_url: https://aaaooai.github.io/posts/" slug "/" > outfile
    c=2; print > outfile
    next
}

c == 1 {
    gsub(/^zenn_/, "")
    print > outfile
    next
}

{
    print > outfile
}
```

やっていることはシンプルです。

1. フロントマター（`---` で囲まれた部分）を読み込む
2. `zenn_` プレフィックスを取り除く
3. `canonical_url` を追加してオリジナルの Hugo 記事を指す
4. 本文はそのまま出力する

`canonical_url` を設定することで、Zenn に投稿してもオリジナルはこのブログだと検索エンジンに伝えられます。

個人用のツールなのでURLの前半部分は固定です。環境変数から取得してもいいかもしれないですね、おいおい直すかもしれません。

## GitHub Actions

[GitHub Pages + Hugo でブログを公開する](https://aaaooai.github.io/posts/github-pages-hugo-setup/#8-github-actions-%E3%81%A7%E3%83%87%E3%83%97%E3%83%AD%E3%82%A4%E8%A8%AD%E5%AE%9A)で説明したWorkflowに設定を追加しています。このWorkflowもリポジトリに置いてあるので、興味があればご覧ください。

```yaml
sync-zenn:
  runs-on: ubuntu-latest
  steps:
    - name: Checkout
      uses: actions/checkout@v6
      with:
        fetch-depth: 2
    - name: Sync to Zenn articles
      run: |
        install -Dd articles
        changed=$(git diff --name-only HEAD~1 HEAD -- 'content/posts/*.md')
        for f in $changed; do ./scripts/sync-zenn.awk "$f"; done
        git config user.name 'github-actions'
        git config user.email 'github-actions@github.com'
        git add articles/
        git diff --staged --quiet || (git commit -m 'sync articles from content/posts' && git push)
```

`main` にプッシュされると、前のコミットとの差分で変更された記事だけを変換して `articles/` にコミットします。`git diff --staged --quiet ||` で差分がない場合はコミットとプッシュをスキップします。

## まとめ

- `content/posts/` に書くだけで Hugo と Zenn の両方に投稿できる
- `zenn_` プレフィックスでフロントマターを共存させる
- AWK スクリプトで変換、GitHub Actions で自動同期
- `canonical_url` でオリジナルの所在を明示できる
