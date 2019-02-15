---
layout: post
title: "LoveSeulgi Project - Django Custom Command"
date: 2019-02-12
excerpt: "Django Custom Command"
tags: [python, django, customcommand]
comments: false
---

# Django Custom Command

[ 주의! 본 포스팅은 내용이 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.]

보통 Management Command 라고 말하는데 난 Custom Command 가 입에 붙어버렸다.



### Custom Command 란?

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/command_help.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/command_help.png"></a>
</figure>

콘솔을 키고 프로젝트 폴더에서 ```python manage.py help``` 명령어를 실행하면 위와같이 Django에 내장된 커맨드들이 보인다. 대표적으로 Django 실행할때 사용하는 ```python manage.py runserver```도 마찬가지로 커맨드중 하나이다.

간단하게 말해서 내가 원하는 로직을 구현시키는 커맨드를 만든다고 말하는게 맞는거같다. 
나는 크롤링관련 커맨드를 만들것이기 때문에 **crawl** 이라는 커맨드를 생성하겠다. 





### Command 등록시키기

```
project
  └─app
      └─management
         │  __init__.py
         └─commands
                crawl.py
                __init__.py
```

최종적으로 폴더 구조는 위와 같아야한다.

Custom Command 파일 위치는 ```project/app/management/commands/{command}.py``` 라고 알아두면 편할듯하다.

__ init __.py 는 파이썬이 이 경로에 있는 파일을 모듈로 인식할수있도록 생성해주는거라고 알고있다. 파일에 내용은 따로 적을 필요없음!

crawl.py 에서 커맨드의 기능을 구현하면된다. 파일명이 커맨드명이 되니까 기억해두도록하자. 

ex) 파일명이 crawl.py 면 ``` python manage.py crawl``` 로 실행할 수 있다.

저기까지 끝났다면 ```python manage.py help``` 명령어를 실행해보도록하자.

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/command_help_success.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/command_help_success.png"></a>
</figure>

정상적으로 crawl 커맨드가 등록된걸 확인할 수 있다.





### Command 실행시키기

커맨드를 등록했으니 제대로 실행이되는지 간단하게 입력받은 파라미터를 출력해주는 코드를 작성해 실행시켜보도록 하자.

```python
from django.core.management.base import BaseCommand


class Command(BaseCommand):
  help = "seulgi image crawler"

  def add_arguments(self, parser):
    parser.add_arguments("name",
                         nargs=1,
                         type=str,
                         help="name")

  def handle(self, *args, **options):
    name = option["name"][0]

    print(name)
```

먼저 BaseCommand 를 불러와서 클래스를 하나 생성해준다.

그 아래 help 는 커맨드에 대한 설명이라고 생각하면 될 듯하다.

그리고 그 아래에 있는 두 함수에 대해서 알아보자.



#### add_arguments
커맨드를 실행 시 추가적으로 파라미터를 받는 함수이다.

함수안에 ```parser.add_argument(key, nargs, type, help)``` 를 사용하여 파라미터를 추가 등록시키면된다.

- key : 파라미터의 이름을 지정
- nargs : 받을 파라미터의 갯수. 파라미터 갯수가 유동적이라면 ```nargs = +``` 로 바꿔주면된다. 
- type : 받을 파라미터의 타입
- help : 파라미터에 대한 설명



#### handle
실질적으로 커맨드가 동작하는 부분이다. main() 함수라고 생각하면 편할거같다.

입력한 파라미터를 받아오는 방법은 ```options["key"][0]``` 으로 받아 사용하면된다.

"key" 부분에는 위 add_arguments에서 지정해준 key 를 넣으면된다.



소스 구현이 끝났다면 아까 등록했던 커맨드를 실행해보도록 하자.

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/command_success.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/command_success.png"></a>
</figure>

입력받은 파라미터가 정상적으로 출력되었다.

이상으로 Custom Command 구현이 끝났다.

다음에는 Selenium 으로 구글 이미지 크롤링을 진행할 예정이다.

