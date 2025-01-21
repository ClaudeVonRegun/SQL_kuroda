-- 問題 1
-- 問題: 全てのユーザーの名前と姓を取得してください。
-- 説明: usersテーブルのfirst_nameとlast_nameのすべてのレコードを取得するクエリを作成します。

SELECT `first_name`, `last_name`
FROM `users`;

-- 問題 2
-- 問題: 「John Doe」が投稿したツイートをすべて取得してください。
-- 説明: usersテーブルとtweetsテーブルを結合し、rst_nameが”John”で、last_nameが”Doe”のユー
-- ザーのツイートを取得します。

SELECT `tweet` FROM `users`
LEFT JOIN `tweets`
ON users.id = tweets.user_id
WHERE first_name = "John" AND last_name = "Doe";

-- 問題 3
-- 問題: 「Jane Smith」が投稿したリプライをすべて取得してください。
-- 説明: usersテーブルとreplysテーブルを結合し、first_nameが”Jane”で、last_nameが”Smith”のユー
-- ザーのリプライを取得します。

SELECT `reply`
FROM  `users`
LEFT JOIN `replys`
on users.id = replys.user_id
WHERE first_name = "Jane" AND last_name = "Smith";


-- 問題 4
-- 問題: どのツイートにもリプライをしていないユーザーの名前と姓を取得してください。
-- 説明: replysテーブルにレコードが存在しないusersテーブルのユーザーを取得します。

SELECT `first_name`, `last_name`
FROM `users`
LEFT JOIN `replys`
on users.id = replys.user_id
WHERE replys.user_id IS NULL;

-- 問題 5
-- 問題: 「Charlie Brown」が投稿したツイートの数をカウントしてください。
-- 説明: usersテーブルとtweetsテーブルを結合し、rst_nameが”Charlie”で、last_nameが”Brown”の
-- ユーザーが投稿したツイートの件数をカウントします。

SELECT COUNT(tweets.id)
FROM `users`
INNER JOIN `tweets`
ON users.id = tweets.user_id
WHERE first_name = "Charlie" AND last_name = "Brown";

-- 問題 6
-- 問題: もっともリプライが多いツイートのIDとリプライ数を取得してください。
-- 説明: replysテーブルを使って、各ツイートに対するリプライの数をカウントし、一番多いリプライ数を
-- 持つツイートIDを取得します。

SELECT tweet_id, count(*) AS reply_count
FROM `replys`
GROUP BY `tweet_id`
HAVING reply_count = (
  SELECT MAX(cnt)
  FROM (SELECT count(*) AS cnt
        FROM `replys`
        GROUP BY `tweet_id`)counts
);

-- 始めに思考した文。
-- SELECT temp.tweet_id, temp.cnt2
-- FROM (SELECT `tweet_id`, COUNT(*) cnt2 
--       FROM `replys` 
--       GROUP BY `tweet_id`) temp
-- WHERE temp.cnt2 = (
--   SELECT MAX(cnt) 
--   FROM (
--     SELECT count(*) cnt 
--     FROM `replys` 
--     GROUP BY `tweet_id`) num
-- );


-- 問題 7
-- 問題: 全てのツイートと、それに対するリプライがあればその内容も取得してください。
-- 説明: tweetsテーブルとreplysテーブルを結合して、各ツイートとそのリプライを取得します。リプライ
-- がない場合はツイートだけ表示されます。

SELECT `tweet`, `reply`
FROM `tweets`
LEFT JOIN `replys`
ON tweets.id = replys.tweet_id;


-- 問題 8
-- 問題: ユーザーごとのツイート数とリプライ数を取得してください。
-- 説明: 各ユーザーのツイート数とリプライ数を集計して、それぞれを表示します。

SELECT users.id, users.first_name, users.last_name, COUNT(DISTINCT tweets.id), COUNT(DISTINCT replys.id)
FROM `users`
LEFT JOIN `tweets`
ON users.id = tweets.user_id
LEFT JOIN `replys`
ON users.id = replys.user_id
GROUP BY users.id;

-- 重複を省く！！
-- COUNT(DISTINCT )を使う！
-- (クロス積が発生するため)


-- 問題 9
-- 問題: もっとも多くリプライを投稿したユーザーの名前と姓を取得してください。
-- 説明: replysテーブルを使って、リプライをもっとも多く投稿したユーザーを特定し、そのユーザーの名
-- 前と姓を取得します。

SELECT users.first_name, users.last_name, COUNT(replys.id) AS max_reply_number
FROM `users`
INNER JOIN `replys`
ON users.id = replys.user_id
GROUP BY replys.user_id
HAVING max_reply_number = (
	SELECT MAX(cnt) 
	FROM (SELECT count(replys.id) AS cnt
        FROM `replys`
        GROUP BY replys.user_id
			 )count
);

-- 間違えて”最も多くのリプライを獲得したユーザーを探していたのでその記録も復習用に残す”
-- SELECT temp2.user_id, temp2.first_name, temp2.last_name, SUM(temp2.counts) AS max_reply_count
-- FROM(
--   SELECT temp.first_name, temp.last_name, temp.tweet_id, temp.user_id, SUM(temp.reply_count)  AS counts
--   FROM (SELECT users.first_name, users.last_name, replys.tweet_id, tweets.user_id, COUNT(replys.tweet_id) AS reply_count
--           FROM `replys`
--           LEFT JOIN `tweets`
--           ON replys.tweet_id = tweets.id
--           LEFT JOIN `users`
--           ON tweets.user_id = users.id
--           GROUP BY replys.tweet_id
--        )temp
--   GROUP BY temp.tweet_id
-- )temp2
-- GROUP BY temp2.user_id
-- HAVING max_reply_count = (
--   SELECT MAX(counts) 
--   FROM (
--     SELECT SUM(reply_count)  AS counts
--     FROM (SELECT tweets.user_id, COUNT(replys.tweet_id) AS reply_count
--            FROM `replys`
--            LEFT JOIN `tweets`
--            ON replys.tweet_id = tweets.id
--            LEFT JOIN `users`
--            ON tweets.user_id = users.id
--            GROUP BY replys.tweet_id
--          )t
--   GROUP BY t.user_id
--   ) count
-- );
-- ①まずはreplys.tweet_id毎のreplys.idの数の合計を探す。
-- ②次にこのcountsをtweews.user_id毎に合計したものを取る。
-- ③そのHAVINGで最大値とそのtweets.user_idを取る


-- 問題 10
-- 問題: すべてのツイートの内容と、それを投稿したユーザーの名前を取得してください。ただし、リプラ
-- イもツイートとして扱い、それがどのツイートに対するリプライかも表示してください。
-- 説明: tweetsテーブル、replysテーブル、usersテーブルを結合し、ツイートとリプライを含むすべての
-- 投稿とそれに関連するユーザー情報を取得します。

SELECT posts.tweet_id, posts.reply_id, posts.all_post, source_id, source, users.id AS user_id, users.first_name, users.last_name
FROM(
  SELECT tweets.id AS tweet_id , NULL as reply_id, tweets.tweet AS all_post, NULL AS source_id, NULL AS source, tweets.user_id
  FROM `tweets`
  UNION ALL
  SELECT NULL AS tweet_id, replys.id AS reply_id, replys.reply AS all_post, tweets.id AS source_id, tweets.tweet AS source, replys.user_id 
  FROM `replys`
  LEFT JOIN `tweets`
  ON replys.tweet_id = tweets.id
)posts
INNER JOIN `users`
ON users.id = posts.user_id;

-- 縦に結合するときはUNIONを使うイメージ！！！
