---
layout: post
title: "LoveSeulgi Project - Django Media Files"
date: 2019-02-21
excerpt: "How to use media files at Django"
tags: [python, django, media files, image]
comments: true
---
# Django Media Files

[ 주의! 본 포스팅은 내용이 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.]



Django 에서 파일 관리 종류(?) 에는 static files 와 media files 가 있다.

static files 는 admin 이 설정해준 고정적인 파일들.

- css
- js
- image ( icon, background 등)

media files 는 유저가 올릴수도있는 동적인 파일들.

- 업로드 가능한 파일 ex)이미지



이 중에서 Media Files 에 대해서 알아볼것이다.

<br/>

## Media Files

이미지를 예로 들겠습니다.

`settings.py` 에는 media 에 접근할 경로와 파일이 저장될 경로를 지정해준다.

```python
# Media files

MEDIA_URL = "/media/"
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
```

- `MEDIA_URL` : media 파일들의 url 경로
- `MEDIA_ROOT` : media 파일이 업로드되었을때 저장될 경로



`urls.py` 에서는 media 에 접근할 수 있도록 url routing 을 해준다.

```python
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # urls..
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

이렇게 설정해주고 난뒤 media 파일을 하나 생성해보자.



### Result

파일을 업로드하는 템플릿이 이미 구현이 되어있다면 좋겠지만 아닌 경우엔 shell 을 통해 생성해보자.

[ 파일 명 및 설정값은 제 프로젝트 기준입니다. ]

- `python manage.py shell` 명령어로 shell 에 접속
- `from gallery.models import Album`  파일을 업로드해줄 Model import
  - 단, Model 안에 미디어 파일을 업로드 할 수 있는 필드가 있어야함
  - ex) ImageField
- `a =  Album()` 으로 Model 객체 생성. Album() 에는 필드값들을 넣어준다
- `a.photo.save("이미지명", "이미지경로")` . 두 인자값을 지정해준 뒤 shell 을 닫는다



예를 들어 등록한 파일이 `/media/image/seulgi/0194f823861e479f99953c4046d10ac6.jpg` 에 저장되어있다면 Django 서버를 실행시킨 뒤 서버url:8000/파일경로
에 접속한다.



<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/media_url.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/media_url.png"></a>
</figure>

이와 같이 등록했던 사진이 브라우저에 나타나면 성공이다.
