---
layout: post
title: "LoveSeulgi Project - Use Django Model"
date: 2019-02-20
excerpt: "save crawl data to django model & Django admin"
tags: [python, django, model, duplicate check, django admin]
comments: true
---
# Save Crawl Data to Django Model

[ 주의! 본 포스팅은 내용이 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.]

이미지를 수집하는 크롤러는 만들었는데 저장할 DB 를 안만들었다.. 그래서 이제 만들겁니다.. 
- 이 포스트를 보기전에 [Django Media Files](https://sprumin.github.io/django_media_files/) 를 먼저 보고오는걸 추천합니다.
- Media Files 설정을 해주지 않으면 이미지가 정상적으로 저장되지 않아요.

<br/>

### Make Django Model

Django Model 은 기본적으로는 sqlite3 를 제공하며 RDBMS 만을 지원한다. Mysql, Postgresql 등 다른 DB 와 연동하고 싶다면 `settings.py` 에서 설정해줄 수 있다. 프로젝트를 만든 뒤 `python manage.py migrate` 명령어를 실행하면 db.sqlite3 파일이 프로젝트 폴더 안에 만들어진것을 볼 수 있다.

일단 `models.py` 에 아래와 같은 소스를 작성해보았다.

```python
from django.db import models

class Album(models.Model):
    id = models.AutoField(primary_key=True)
    photo = models.ImageField(upload_to="image/seulgi", unique=True)
    name = models.CharField(max_length=24, default="Seulgi")
    title = models.CharField(max_length=64)
    photo_link = models.CharField(max_length=2048)
    source = models.CharField(max_length=2048)
    views = models.IntegerField(default=0)
    thumbs = models.IntegerField(default=0)
    is_gif = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
```

- ImageField 를 사용하려면 `pip install PILLOW` 명령어를 통해 PIL 설치를 반드시 해주어야한다.

- class Album 은 DB 의 테이블이고 그 아래 변수들은 column 이다... 라고하니까 설명이 끝난거같네요

- 컬럼명 = models.변수타입(상세설정) 이라고 생각하면 될 듯하다.

- `def __str__(self)` 은 모델 클래스의 객체의 문자열을 리턴해주는 함수이다.

  - 예를 들자면 row 하나가 (id=1, photo=test, name=sprumin, title=hello ...) 의 값을 가졌고 모델에

    ```python
    def __str__(self):
        return self.title
    ```

    라는 함수가 선언되어있다.

  - `views.py` 에서 `Album.objects.get(id=1)` 을 출력하게되면 id 가 1인 row 의 title 값을 출력하게된다.

  - (설명이 미흡하겠지만 내가 알고있는한에서 작성하다보니 이렇게되는듯하다..)

<br/>

### Data Valid Check

정상적인 이미지가 크롤링되었는지, 중복된 이미지가 아닌지 체크하기로 했다. 

이 소스코드는 [이전 포스트](https://sprumin.github.io/crawling_with_selenium/) 버전에서 추가로 작성된 소스코드이다.

```python
result = list()

for image in images_info:
    if not Album.objects.filter(photo_link=image[0]).exists()
        and not TrashCan.objects.filter(photo_link=image[0]).exists():
        driver.get(image[0])
        valid = input()
        
        if valid:
            data = ("trash", image[0])
        else:
            data = image
        
        result.append(data)

    driver.quit()
    
    # 아래 Save Crawl Data 부분의 함수를 호출하는 부분이다.
    # 실제 소스코드에 작성된 함수 이름과 다르다.
    function("Seulgi", data)
```

images_info 는 크롤링된 데이터들이 [(data),(data), ... ]  형태로 저장되어있는 변수이다. 이전 소스와 연결되므로 기억해두길.

Album 모델은 크롤링된 이미지와 그 상세정보가 저장될 모델이고, TrashCan 모델은 부적절한 이미지의 링크만 저장하여 다음 크롤링때 부적절한 이미지들을 재 검사하지 않도록 하는 모델이다.

`모델명.objects.filter('조건').exists()` 는 Album 테이블에서 조건에 맞는 row 가 하나라도 있으면 True 없다면 False 를 반환한다. 위에 `if not` 을 사용하여 False 가 반환될 경우에만 이미지를 저장하는 루프를 타도록 하였다.

저렇게 모으고보니 예외가 너무 많았다. 페이지가 만료된경우, 화질이 안좋은경우, 관계없는 사진인 경우 등 다양한 경우가 많았다. crontab 으로 봇을 돌리고 싶었지만 부적절한 데이터가 삽입될 경우를 생각하니.. 차마 그럴 수 없었다. 나중에 이미지 학습을 할 수 있게된다면 가능할지도..?

그래서 selenium 으로 이미지를 하나하나 띄운뒤 저장할 이미지는 엔터로 리스트에 추가하고 부적절한 이미지들은 ("trash", 이미지링크) 형태로 리스트에 추가하였다.

데이터 유효성 검사(?) 를 마쳤으니 `function("Seulgi", data)` 함수로 넘어가자. 

<br/>

### Save Crawl Data

이전 포스트에서 크롤러를 다 구현했으나 저장할 DB 를 만들어두지 않아 출력만했다.

위에서 모델 생성도 끝마쳤으니 저장해보도록하자.

```python
from gallery.models import Album, TrashCan

from io import BytesIO

import os
import requests
import uuid

def function(name, data)
    exts = ["jpg", "jpeg", "gif", "png"]
    for row in data: 
        try:
            if row[0] == "trash":
                t = TrashCan(photo_link=row[1])
                t.save()
                print(f"Save Trash : {row[1]}")
            else:
                a = Album(name=name, title=row[1].replace("\\u0027", ""), photo_link=row[0],                              source=row[2])
                filename = uuid.uuid4().hex
                ext = os.path.basename(row[0]).split(".")[-1]

                if not ext in exts:
                    ext = "jpg"
                if ext == "gif":
                    a.is_gif = True

                a.photo.save(f"{filename}.{ext}", BytesIO(requests.get(row[0]).content))
                print(f"Save Image : {row[1]}")

            except Exception as e:
                print(f"Save Error : {e}")
```

- `requests` 는 `pip install requests` 명령어로 다운로드 받아야한다.

데이터를 DB 에 삽입하기 좋은 형태로 변환하여 저장해볼것이다.

DB에 삽입할 row 를 생성하는데 비 정상적인 데이터가 들어갈 상황을 생각해서 예외 처리를 해주었다. 

먼저 row[0] 번째 값이 "trash" 인지 검사한다. data 에는 정상적인 이미지가 담긴 `(이미지링크, 제목, 소스)` 와 부적절한 이미지링크가 담긴 `("trash", 이미지링크)` 로 두가지 형태를 갖고있다. 여기서 row[0] 번째 값이 "trash" 라면 부적절한 이미지링크가 담긴 row 기때문에 TrashCan 모델에 저장할것이고 아닐경우 정상적인 이미지이기 때문에 Album 모델에 저장할것이다. 

위에 보이는 `Album()`과 `TrashCan()` 은 INSERT INTO 문이라고 생각하면 된다. 테이블에 새로운 row 를 삽입해주는 명령어다.

이미지 이름이 중복될 수 있기때문에 uuid 를 사용하였고 나중에 gif 이미지만 보여주는 카테고리를 따로 구현해줄  예정이라 gif 인지 아닌지도 체크해주었다.

이미지를 저장할때 image link 를 바로 저장하면안되고 위 처럼 BytesIO 를 통해 이미지만 가져와서 변환시켜주어야한다.

그리고 이미지가 제대로 저장되었는지 확인하기위해 print 한 줄씩 해주었다.

<br/>
### Django admin

- url 설정

이미지(데이터)가 잘 저장되었는지 확인하는 방법은 여러가지가있다. sqlite3에 직접 접근하여 확인할수도있고 ImageField 에서 설정한 폴더에 들어가 확인해 볼 수도 있지만( Media Files 한정 ) Django 에서는 Model 을 관리하기 쉽게 Django admin 이란걸 제공하기 때문에 Django admin 을 사용해보도록하겠다.

일단 admin 에 접속할 url 설정을 해야하는데 Django 프로젝트를 생성하면 기본적으로 설정되어있기에 따로 건드릴건없다. `project/project/urls.py` 에 보면 아래와 같이 설정이 되어있는걸 확인할 수 있다.

```python
from django.contrib import admin
# django 2.0 이상부터는 url 이 아닌 path 로 routing 이 가능하다.
from django.urls import path

urlpatterns = [
    path("admin/", admin.site.urls),
]
```

`django서버주소:8000/admin/` 에 접속하면 admin 사이트가 나타난다! 라고 생각하면 될 듯하다.

-  admin site 설정

`project/app/admin.py` 에서 아래 소스코드를 작성하였다.

```python
from django.contrib import admin

from gallery.models import Album

class AlbumAdmin(admin.ModelAdmin):
    list_display = ("name", "photo", "title", "source", "views", 
                    "thumbs", "is_gif", "created_at", )
    ordering = ("-id", "views", "thumbs", )
    list_filter = ("is_gif", )
    readonly_fields = ("photo", "source", )

admin.site.register(Album, AlbumAdmin)
```

admin.py 에서 커스텀해주지 않으면 그 모델은 django admin page 에서 관리할 수 없다. 말이 이상한거같은데 간단하게 말해서 위처럼 설정을 해줘야 웹에서 관리가 가능하다. 

-  `AlbumAdmin(admin.ModelAdmin)` : admin page 에서 Model 을 관리할때 유저 편의에 맞게 세팅할 수 있도록 설정하기위해 선언한 클래스 
- `list_display` : row list 에 보여질 필드들
- `ordering` : row list 를 정렬하는 기준이 되는 필드들 
  - -id 로 하면 최신순 데이터부터 보여지기 때문에 -id 로 한다.
- `list_filter` : 특정 값에 따라 row list 에 있는 데이터들을 필터링하는 필드들
- `readonly_fields` : 읽기 권한만 주어지는 필드들
- `admin.site.register(Album, AlbumAdmin)` : AlbumAdmin 의 설정값에 따라 admin site 에서 테이블을 관리할 수 있게 등록시켜주는 것.



- admin 계정 생성

콘솔에 `python manage.py createsuperuser` 를 입력하고 아이디, 이메일, 비밀번호를 설정해주면 끝이난다



admin 까지 작성이 끝났다면 admin site 에 들어가 데이터들을 확인할 차례

 `localhost:8000/admin` 에 접속하고 로그인 한 후 admin.py 에서 등록한 모델을 클릭하면 아래처럼 크롤링 데이터가 정상적으로 테이블에 저장되었는지 확인할 수 있다. 

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/django_admin.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/django_admin.png"></a>
</figure>

크롤러를 만들고 데이터를 저장하는 일까지 끝났다. 이제 본격적으로 페이지를 만들거같은데 진짜로 css 에는 재능이 하나도 없어서 갈길이 멀다.. 템플릿을 따오던지 하는게 마음이 편할거같다.

다음에는 Django Custom User Model 을 만들어 볼 것이다.