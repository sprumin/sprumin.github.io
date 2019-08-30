---
layout: post
title: "Seulgi Fan Page Project - User Events"
date: 2019-07-19
excerpt: "회원가입, 로그인 로그아웃과 Django Form"
tags: [python, django, user, register, signup, login, signin, logout, signout, form, template, 회원가입, 로그인]
comments: true
---
# User Events

[ 주의! 본 포스팅은 내용이 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.] 

이번엔 회원가입부터 로그인 로그아웃까지 구현하는 과정을 포스팅하기로했다. 

근데 아마 Django Form 에 대해서 이야기가 더 많을거 같다. 왜냐하면 Django 에는 login, logout 모듈이 제공되기 때문에.. 회원가입도 이전 포스팅에서 create_user 메소드도 구현했고 입력받아서 서버로 전달되는 부분만 구현하면 된다.

<br>

### Django Form

App 폴더 아래 forms.py 라는 이름으로 생성해서 사용하는데 클라이언트단에서 데이터를 입력받을 Form 들의 
형태(?)를 정의하는 파일이다. 우선 회원가입, 로그인에 사용될 Form 을 작성해보자. 로그아웃의 경우 따로 입력받을게 없기때문에 Form 을 생성해줄 필요가없다.



#### 회원가입 Form

```python
class UserCreationForm(forms.ModelForm):
    # email ~ password2 입력받을 필드의 설정 값 세팅
    email = forms.EmailField(
        label='E-mail',
        required=True,
        widget=forms.EmailInput(
            attrs={
                'placeholder': 'E-mail address',
                'required': 'true',
            }))
    username = forms.CharField(
        label='Username',
        required=True,
        widget=forms.TextInput(
            attrs={
                'placeholder': 'Username',
                'required': 'true'
            }))
    password1 = forms.CharField(
        label='Password',
        widget=forms.PasswordInput(
            attrs={
                'placeholder': 'Password',
                'required': 'true'
            }))
    password2 = forms.CharField(
        label='Password confirmation',
        widget=forms.PasswordInput(
            attrs={
                'placeholder': 'Password confirmation',
                'required': 'true'
            }))
    
    # Form 에 사용될 모델, 필드를 정의
    class Meta:
        model = User
        fields = ('email', 'username', 'password1', 'password2',)
    
    # form 으로 값이 들어오면 데이터의 valid 를 체크한 뒤 저장 
    def save(self, commit=True):
        user = super(UserCreationForm, self).save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user
```

회원가입 시 입력받을 폼에대해 설정하고 그값을 바로 DB 에 save 하는 소스코드이다.

 `필드명 = forms.CharField()` 까지만 적어줘도 문제는 없지만 label, required, placeholder 같은 세세한 설정을 위해 적어주었다. 



#### 로그인 Form

```python
class UserSignInForm(forms.ModelForm):
    email = forms.EmailField(
        label='E-mail',
        required=True,
        widget=forms.EmailInput(
            attrs={
                'placeholder': 'E-mail address',
                'required': 'true',
            }))
    password = forms.CharField(
        label='Password',
        widget=forms.PasswordInput(
            attrs={
                'placeholder': 'Password',
                'required': 'true'
            }))

    class Meta:
        model = User
        fields = ('email', 'password', )
```

회원가입 Form 과 크게 다른것없으니 설명하지 않아도 될 것 같다.

<br>

### URL Routing

회원가입, 로그인, 로그아웃 View 에 접근하기 위해 user/urls.py 를 작성해보았다.

```python
from django.urls import path
from . import views


urlpatterns = [
    path("signup/", views.UserSignUpView.as_view()),
    path("signin/", views.UserSignInView.as_view()),
    path("signout/", views.signout)
]
```

간단하게 signup 으로 예를들면 `http://127.0.0.1:8000/signup` 이라는 url에 접속했을 때 SignUpView 에서 처리하겠다 라는 내용이다. 아래 signin 과 signout 도 마찬가지.

`path(경로, 매칭시켜줄 view)` 와 같은 형식으로 urlpatterns 에 넣어주면된다.

해당 프로젝트에서는 `project/projects/urls.py` 에서 각 app 별로 url routing 을 해놨기때문에 user 앱에서 `"signup/"` 접속경로는 `http://127.0.0.1:8000/user/signup` 처럼 작성될것이다.

<br>

### View 기능 구현

form 을 완성했으니 저 form 을 template 에 보내준뒤 값을 받아오는 기능을 구현해야한다.

미리 설명하자면 GET 요청이 오면 템플릿에 Form 을 전송해줄것이고 POST 요청이 들어오면 회원가입 또는 로그인에 필요한 값을 받아 요청을 처리해주는 함수이다.

간단하게 GET 은 접속 시 보여질 기능을 view 에 요청, POST 는 그 기능을 수행하는데 필요한 값을 받아 view 로 전송하는것.

`messages` 함수는 template 에서 alert 를 띄워줄 메세지를 전송하는데 사용된다. 추후에 포스팅하겠지만 포스트가 없을경우 구글에 검색해보길.



#### 회원가입 View

```python
from django.contrib import messages
from django.shortcuts import render
from django.views import View

from user.models import User


class UserSignUpView(View):
    def get(self, request):
        # 로그인 체크
        # 로그인 상태일경우 회원가입을 할 이유가 없음
        if request.user.is_authenticated:
            return redirect("/")
        
        # forms.py 에서 불러온 회원가입 form 을 변수에 저장
        form = UserCreationForm
        
        # render 함수를 이용하여 회원가입 template 과 사용될 회원가입 form 을 전송
        return render(request, "user/signup.html", {"form": form})

    def post(self, request):
        # form 을 불러옴과 동시에 POST 로 서버에 전송된 값을 form 에 삽입
        form = UserCreationForm(request.POST)
        
        # 위에서 Data 를 form 에 삽입했으니 form 이 정상적이라면 기능수행 아니라면 에러 표시
        # 이전 UserManager 에서 생성한 create_user method 가 여기서 쓰이게 된다
        # UserManager 에서 password 길이가 8자 미만이라면 ValueError 를 리턴하게 해놓았기 때문에
        # try except 문으로 에러를 예외처리해준다.
        if form.is_valid():
            try:
                User.objects.create_user(**form.cleaned_data)
            except ValueError:
                messages.error(request, "Password too short!")
            else:
                # 정상적으로 회원가입이 완료되었으니 로그인 페이지로 redirect
                return redirect("/user/signin")

        return redirect("/user/signup")
```

나는 클래스형 View 가 개발하기도 편하고 보기도 좋은거같아서 클래스형 View로 개발하고있다.

`http://127.0.0.1/user/signup` 에 접속했을 때 위 view 와 매칭되고 http method 를 판별한 뒤 기능을 수행한다.

Django 에서 현재 로그인정보나 template 에서 view 로 넘어오는 값은 전부 request 라는 인자에 포함되어있다.

위 소스에서 볼 수 있듯 method 와 유저의 로그인정보, form 으로 입력받은 값을 request 에서 찾아 사용한다.



#### 로그인 View

```python
from django.contrib import messages
from django.contrib.auth import authenticate, login
from django.shortcuts import render
from django.views import View

from user.models import User


class UserSignInView(View):
    def get(self, request):
        # 로그인 체크
        # 로그인 상태일경우 로그인을 다시 할 이유가없음
        if request.user.is_authenticated:
            return redirect("/")
        
        # forms.py 에서 로그인 폼을 불러와 변수에 저장
        form = UserSignInForm
        
        # render 함수를 이용해 로그인 template 과 로그인 폼을 전송
        return render(request, "user/signin.html", {"form": form})

    def post(self, request):
        # POST 로 넘어온 값 email, password 를 변수에 저장한다
        email = request.POST.get("email")
        password = request.POST.get("password")
        
        # authenticate 함수를 이용해서 email 과 password 를 검증하여 로그인 가능한지 체크한 뒤
        # 유저가 존재한다면 user 변수에 값 저장
        user = authenticate(email=email, password=password)
        
        # 유저가 있을 경우 login 함수로 로그인 후 메인페이지로 리턴
        # 그렇지 못할 경우 에러 메세지 alert 후 로그인 페이지 reload
        if user:
            login(request, user)

            return redirect("/")
        
        messages.error(request, "Invalid email or password")

        return redirect("/user/signin")
```

`http://127.0.0.1:8000/user/signin` 으로 요청이 들어올 경우 매칭되어 기능을 수행하는 view 이다.

authenticate 함수같은 경우 email 대신 username 이 들어가도 괜찮지만 이 프로젝트에서는 username 대신 email 로 로그인하기로 했으니 email 로 검증한다.



#### Logout View

```python
from django.contrib.auth import logout
from django.shortcuts import render


def signout(request):
    logout(request)

    return redirect("/")
```

`http://127.0.0.1:8000/user/signout` 으로 요청이 들어오면 로그아웃해준다.

Django 에 생각보다 많은 모듈이 구현되어있어서 간단간단하게 개발하는데 큰 어려움은 없는거같다.





### Templates ( 회원가입, 로그인 )

이 프로젝트에선 템플릿을 상속받아 사용하도록 해놓았지만 포스팅할땐 간단하게 해당 기능만 작동하도록 작성할것이다.

base.html 템플릿을 상속받아 사용하는 방법은 추후에 포스팅하도록 하겠다.

일단 프로젝트 폴더 하위에 templates 폴더를 생성해준뒤 settings.py 에서 TEMPLATES 를 찾아 아래와같이 수정해준다.

위 views.py 를 보면 템플릿경로가 `user/signup.html` 형태로 되어있다. 경로는 각자 편한대로 설정해줘도 상관업지만 이 프로젝트에서는 templates 폴더 하위에 user 폴더를 만들어 그 안에 회원가입, 로그인 template 을 저장한다.

#### settings.py

```python
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        # 이부분 수정. templates 경로 설정 부분이다.
        'DIRS': ['templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]
```



#### 회원가입 Template

```python
<html>
  <head>
  </head>
  <body>
    <h1> 회원가입 </h1>
    <form method="POST">
      <!-- 필드별로 나누지 않고 {{ form.as_p }} 를 사용해도 된다.-->
      Email : {{ form.email }}
      Username : {{ form.username }}
      password : {{ form.password1 }}
      password confirmation : {{ form.password2 }}
    
      <input type="submit" value="회원가입">
    </form>
  </body>
</html>
```

`{{ form_as.p }}` 를 사용하면 template 에 전송된 form 의 필드에 맞게 알아서 위처럼 만들어준다.

view 에서 template 으로 전송한 값을 받을때는 {{ 변수 }} 형태로 사용가능하다. UserSignUpView 에서 form을 전송했으니 {{ form }} 이라는 변수를 template 에서 사용할 수 있고 form 에 담긴 필드들에 접근가능하게 되어 위처럼 각 필드별로 input form 을 만들어줄 수 있다.

각 필드에 맞게 회원가입 form 을 작성하고 submit 버튼을 누르게되면 view 에 POST 형태로 전달되어 기능을 수행하게된다.



#### 로그인 Template

```python
<html>
  <head>
  </head>
  <body>
    <h1> 회원가입 </h1>
    <form method="POST">
      <!-- 필드별로 나누지 않고 {{ form.as_p }} 를 사용해도 된다.-->
      Email : {{ form.email }}
      password : {{ form.password }}
    
      <input type="submit" value="로그인">
    </form>
  </body>
</html>
```

회원가입 template 과 같아서 설명할게 없는거같다.



### 로그인 확인

회원가입은 로그인으로 확인하거나 admin page 에 접속하여 확인가능하지만 로그인이 되었는지 안되었는지는 당장 확인할 방법이 없기때문에 간단히 로그인 상태를 확인할 수 있는 페이지를 만들어보자

우선 templates/user 폴더 하위에 index.html 파일을 생성해준뒤 아래 소스를 적용시킨다.

#### urls.py

```python
# 위에 urls.py 에 이어서 작성할것.
# urlpatterns 안에 아래 한줄 추가
path("index/", views.index)
```



#### views.py

```python
# 위에 views.py 에 이어서 작성할것.
# 아무데나 아래 소스 추가

def index(request):
    return render(request, "user/index.html")
```



#### index.html

```python
<html>
  <head>
  </head>
  <body>
    {% if request.user.is_authenticated %}
        <h1> {{ request.user.username }} 님 반갑습니다. </h1>
    {% else %}
        <h1> 로그인해주세요 </h1>
    {% endif %}
  </body>
</html>
```

Django template 에서도 if문 for문같은 문법들을 사용할 수 있다.

request 로 현재 접속정보를 받아 로그인 체크를 할 수 있고, 로그인이 되어있다면 로그인 된 유저의 정보도 위와 같이 사용하능하다.

이제 접속해서 로그인한뒤 `http://127.0.0.1:8000/user/index` 에 접속하면 로그인 체크를 할 수있다.

현재 프로젝트에선 삭제된 부분이나 로그인 체크를 보여주기위해 작성하였습니다.



이로써 회원가입, 로그인 기능 및 Django Form 사용에 대해 알아보았다.

회원가입이랑 로그인에 대해 작성하다가 Django Form 까지 한번에 작성하게 되어서 많이 길어진거같다. 한번에 이것저것 하려다보니 몰린거같다...

다음엔 base template 에 대해 포스팅 할 예정이다.