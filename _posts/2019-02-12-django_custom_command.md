---
layout: post
title: "Django Custom Command"
date: 2019-02-12
excerpt: "Django Custom Command"
tags: [python, django, customcommand]
comments: false
---

# Django Custom Command

[ 주의! 본 포스팅은 전문적으로 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.]

보통 Management Command 라고 말하는데 난 Custom Command 가 입에 붙어버렸다.



### Custom Command란?

![command_help](assets/img/post_image/command_help.png)

콘솔을 키고 프로젝트 폴더에서 ```python manage.py help``` 명령어를 실행하면 위와같이 Django에 내장된 커맨드들이 보인다. Django 실행할때 사용하는 ```python manage.py runserver```도 마찬가지로 커맨드중 하나이다.

간단하게 말해서 내가 원하는 로직을 구현시키는 커맨드를 만드는것이다. 구글이미지를 크롤링 하는 커맨드인 **crawl** 커맨드를 만들어 볼 것이다.





### Command 등록시키기

project/
>- app/
>->- management/
>->->- __ init __.py
>->->- commands/
>->->->- __ init __.py
>->->->- crawl.py

커맨드를 등록시키기 위한 폴더 구조는 위와 같다. 

Custom Command 경로는 ```project/app/management/commands/{command}.py``` 라고 알아두면 편할듯하다.
( 마크다운으로 작성하니까 __ <- 언더바 두개에 init 적으니까 글씨 굵어지고 __ 이건 사라진다.. 그래서 __ 하고 init 앞뒤로 띄어쓰기 한번씩 했으니까 기억해두길 )

__ init __.py 는 파이썬이 이 경로에 있는 파일을 모듈로 인식할수있도록 생성해주는거라고 알고있다.
파일에 내용은 따로 적을 필요없음!

위 crawl.py 는 내가 사용할 커맨드 이름을 임의로 지정해준것이니 이름은 자유롭게 바꿔도 상관없다.

저기까지 끝났다면 ```python manage.py help``` 명령어를 실행해보도록하자.

![command_help_success](C:\Users\sprumin\Pictures\loveseulgi이미지파일\command_help_success.png)

