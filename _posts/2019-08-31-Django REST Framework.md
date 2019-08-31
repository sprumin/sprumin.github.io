---
layout: post
title: "Django REST Framework"
date: 2019-08-31
excerpt: "DRF 사용해보기"
tags: [sprumin, django, DRF, django-rest-framework, REST, restapi]
comments: true
---
# Django REST Framework

[주의! 부정확한 내용이 기재되어 있을 수 있습니다. 댓글 또는 이메일로 피드백 부탁드립니다.]

해당 글은 [DRF Tutorial](https://www.django-rest-framework.org/tutorial/quickstart/) 을 기반으로 공부하며 작성되었습니다. 또한 Tutorial 진행과정에 대해선 상세하게 작성하지 않았습니다. Tutorial 진행과정은 위 링크를 참조부탁드립니다.

<br/>

처음에 생각했던 건 django 프로젝트안에 Vue.js 를 연동해서 서버사이드 렌더링을 하려고 했다. 자료를 더 찾아보고 지인들에게 조언을 구해보니 Vue.js 서버와 django 서버를 따로두고 API 통신만 하여 데이터를 주고받는게 더 낫다고 하였다. 그래서 빠른 변경.. 프로젝트를 더 진행하고 난 뒤엔 Vue.js 공부하면서 개발하느라 개발방식을 변경하기에는 무리가 있을거같다.

<br/>

### Django REST Framework 를 사용하는 이유?

django View 에서는 Restful api 를 개발하기에 좋은 환경을 제공하고있다.

```python
from django.views import View


class TestView(View):
    def get(self, request):
        pass
    
    def post(self, request):
        pass
    
    def put(self, request):
        pass
    
	def delete(self, request):
        pass
```

나는 평소 위와같은 형태로 View 를 사용한다.  작년까지만해도 함수형 View 로 개발하고있었는데 ClassView 로 개발하는것이 코드를 작성하기도, 가독성도 훨씬 좋은거같다. 물론 이건 지극히 주관적이고 함수형 View 가 더 좋을때도 있다고 생각한다.

아무튼 django 자체에서도 Restapi 를 구현할 수 있지만 더 쉽고 간편하게 개발하기 위해 Django REST Framework 를 사용해보도록 할 것이다.

DRF 에서 가장 눈에 띈것은 `Router` 와 `Serializer` 기능이다. Router 는 매핑시킨 Viewset 의 parameter 에 맞게 자동으로 urlrouting 을 해주는 것 같다. Serializer 는 직렬화, 역직렬화를 제공해주는데 ORM 을 통해 불러온 Data 를 json, dictionary 형태로 변환시켜주는 역할을 한다.

위 기능은 DRF 를 사용하지 않아도 코드 몇줄만 추가해주면 사용할 수 있는 기능이지만 DRF를 사용하면 더 간결하게, 쉽게 작성하는걸 도와주는 역할을 한다.

<br/>

### serializer.py ( Serializer )

해당 파일은 django 에서 기본적으로 제공해주는 파일이 아니기때문에 app 폴더에 직접 `serializer.py` 를 생성해주어야한다.

```python
from rest_framework import serializers
from .models import User


class UserSerializer(serializers.HyperlinkedModelSerializer):
	class Meta:
		model = User
		fields = ['idx', 'email', 'username']
```

작성해둔 User Model 에 대한 Serializer.py 의 내용이다.

특이점이라고 하면 `serializer.HyperlinkedModelSerializer` 일텐데 `ModelSerializer` 와 다른점은 총 3개라고 한다. [설명 출처](http://raccoonyy.github.io/drf3-tutorial-5/)

- `pk` 필드가 기본요소가 아니다
- `HyperlinkedIdentityField` 를 사용하는 `url` 필드가 포함되어있다.
- 관계는 `PrimaryKeyRelatedField` 대신 `HyperlinkedRelatedField` 를 사용하여 나타낸다.

솔직히 말해선 1번 빼곤 아직 이해가 잘 가지않는다. 일단 튜토리얼이니까 사용하고나서 이해해보려한다. 간단하게 요약하면 해당 Serializer 를 호출하면 ORM 으로 불러온 Data 들을 json 형태로 변환시켜주는 역할을 한다. 호출하고 ORM 을 작성하는 부분은 아래 Viewset 에서 볼 수 있다.

<br/>

### views.py ( ViewSet )

django 의 실질적인 기능들은 View 에서 구현된다. 아래 소스는 DB 에 저장된 User 전부를 불러와 위에서 작성한 serializer 로 데이터를 json 형태로 변환해주는 역할을 한다. 

```python
from rest_framework import viewsets

from user.models import User
from user.serializer import UserSerializer


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all().order_by('-idx')
    serializer_class = UserSerializer
```

queryset 으로 User Model 에 저장되어있는 모든 User 들의 정보를 전부 가져오고 위에서 작성한 UserSerializer 를 호출하여 사용한다. 

신기했던건 return 하는 부분이 없는데 DRF 화면에서 GET 요청을 하게되면 Viewset 에서 작성한 데이터를 볼 수 있다. 아마 Router 에서 Viewset 를 매핑하면서 데이터를 가져오는것 같다 (뇌피셜)

<br/>

### urls.py ( Router )

평소 개발할 때는 각 app 별로 urls.py 를 추가하여 관리하였는데 Router 기능을 보니 굳이 그럴필요 없다고 생각이든다. 만약 app 별 url 관리가 더 좋다하면 변경할 예정이나 현재는 `project/urls.py` 에서 한번에 관리중이다.

```python
from django.urls import path, include
from rest_framework import routers

from user.views import UserViewSet

router = routers.DefaultRouter()
router.register(r'user', UserViewSet, basename='user') 


urlpatterns = [
    path('', include(router.urls)),
    path('api-auth', include('rest_framework.urls', namespace='rest_framework')),
]
```

Router 에 대해 이야기하기 전에 urlpatterns 를 먼저 보도록 하자.

admin page 는 따로 필요없기때문에 `admin/` path 는 삭제하였다.
`api-auth` 는 그냥 rest-framework 에서 제공하는 페이지의 로그인 인증관련 url 인 것 같다.

`path(''), include(router.urls)` 는 DRF 에서 제공하는 router 의 urlrouting 을 django BASEURL 로 설정하겠다 라는 말로 이해하였다. 그럼 이제 router 에 대해 알아보자.

`router = routers.DefaultRouter()` 로 Router 를 생성하고 하단에 `.register` 를 통해 views.py 에서 작성한 Viewset 들을 Router 에 매핑시켜주는 작업을 한다.

위 Tutorial 에서는 작성되어있지 않은데 `.register` 에 `basename` 을 추가해주지 않으면 서버 실행 시 에러가 나게된다. 혹시 에러가 나게된다면 basename 을 추가해주도록하자.

<br/>

`python manage.py runserver` 명령어로 서버를 실행하고 브라우저로 `127.0.0.1:8000/user/` 에 접속하면 `GET` 으로 UserList 가 json 형태로 보여지는것을 확인할 수 있고,  `POST` 로 UserList 에 User 를 추가할 수 있는 Form 도 나타난다. 

추가적인 기능들은 더 공부해봐야 알겠지만 DRF 를 설치/설정하고 Serializer 와 Viewset 그리고 Router 를 이용하여 Restful API 를 사용해보았다.

이젠 각 http method 별 요청을 통해 유저 CRUD 기능을 구현해 볼 예정이다.

