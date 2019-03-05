---
layout: post
title: "Seulgi Fan Page Project - Custom User Model Error"
date: 2019-03-04
excerpt: "FOREIGN KEY constraint failed error from Django Custom User Model"
tags: [python, django, model, custom user model, django admin, foreign key error, foreign key constraint failed]
comments: true
---
# Django Foreign Key constraint failed 

[ 주의! 본 포스팅은 내용이 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.] 

이미지를 첨부하고 싶었으나 다시 에러를 내기가 귀찮았..ㄷ

예전에 Django 공부하다가 `FOREIGN KEY constraint failed` 라는 에러가 한번 났었는데 도대체 무슨 원인인지 몰라서 한참 헤맸었다. 회사 선임님의 도움을 받아 해결했지만 어떻게 해결했는지 잘 모르던 시절.. 아 감사합니다 하고 해결되서 좋아했었다.

그런데 저 에러가 오늘 발견되었다. Django admin 에서 유저관련 데이터를 추가,수정할 때 발생하는 에러같다. 이전에 봤던 에러인데 어떻게 해결한지 기억이 나질않으니 답답했다... 원인을 찾기 어려워했던 이유중 하나가 에러명은 Foreign Key 관련인거 같은데 모델 컬럼에 Foreign Key 가 한번도 사용되지않았다. 

뭐가 문제지..?하면서 DB 도 지워보고 구조도바꿔보고.. 별에 별짓을 다 해본결과 30-40분정도 걸려서 해결했다.

일단 문제는 Custom User Model 을 생성하면서 생긴 user_user 테이블과 기존에 `python manage.py createsuperuser` 명령어로 어드민 계정이 저장된 auth_user 테이블의 상속문제? 때문에 에러가 났던것이다.

Custom User Model 을 사용할 때 settings.py 에 `AUTH_USER_MODEL = 'user.User'` 을 추가하게 되는데 기존의 auth_user 테이블 대신 새로운 user_user 모델을 사용하겠다는뜻이..겠지?  ( 아..아닐수도있어요 )
그런데 나는 기존에 크롤러 데이터를 확인하기위해 auth_user 에 이미 admin 계정이 하나 생성되어있었던 상황..
거기에 user_user 가 하나 더 생겨버렸으니 유저 테이블을 혼동하기 시작한것이다. 그래서 django admin 에서 추가,수정이 안됐던것같다.

<br/>

#### 해결법

migrate 할때 Custom User Model 구현을 끝내고 하면 편하다.

1. db.sqlite3 파일 삭제
2. Custom User Model 을 구현한 app 의 migrations 폴더 삭제
3. python manage.py makemigrations ( 만약 no detected 가 뜨면 python manage.py makemigrations 앱이름)
4. python manage.py migrate

이후에 어드민계정을 생성하고 django admin에 다시 들어가서 추가, 삭제를 해주면 에러가 나지 않을것이다.

생각보다 간단한 이유로 에러가 발생했는데 에러명 때문에 고생좀한것같다.