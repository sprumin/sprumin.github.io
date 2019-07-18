---
layout: post
title: "Seulgi Fan Page Project - User Events"
date: 2019-07-18
excerpt: "회원가입, 로그인 로그아웃 등"
tags: [python, django, user, register, signup, login, signin, logout, signout, 회원가입, 로그인]
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

    class Meta:
        model = User
        fields = ('email', 'username', 'password1', 'password2',)

    def save(self, commit=True):
        user = super(UserCreationForm, self).save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user
```

회원가입 시 입력받을 폼에대해 설정하고 그값을 바로 DB 에 save 하는 소스코드이다.

차례대로 각 필드 설정, 폼을 사용할 모델과 필드명, 자동 저장이라고 생각하면 될듯하다.

username 을 예로들자면 `username = forms.CharField()` 까지만 적어줘도 문제는 없지만 label, required 같은 세세한 설정을 위해 적어주었다. 



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

<br>

### View 기능 구현

form 을 완성했으니 저 form 을 template 에 보내준뒤 값을 받아오는 기능을 구현해야한다.

미리 설명하자면 GET 요청이 오면 템플릿에 Form 을 전송해줄것이고 POST 요청이 들어오면 회원가입 또는 로그인에 필요한 값을 받아 요청을 처리해주는 함수이다.



#### 회원가입 View

```python
from django.http import HttpResponse
from django.shortcuts import render
from django.views import View

from user.models import User


class UserSignUpView(View):
    def get(self, request):
        if request.user.is_authenticated:
            return redirect("/")

        form = UserCreationForm

        return render(request, "user/signup.html", {"form": form})

    def post(self, request):
        form = UserCreationForm(request.POST)

        if form.is_valid():
            try:
                User.objects.create_user(**form.cleaned_data)
            except ValueError:
                return HttpResponse("Password too short!")
            else:
                return redirect("/user/signin")

        return redirect("/user/signup")
```

함수형 View 를 사용할거라면 class 부분부터 아래와 같이 작성하면된다.

```python
def signup(request):
    if request.method == "POST":
        form = UserCreationForm(request.POST)

        if form.is_valid():
            try:
                User.objects.create_user(**form.cleaned_data)
            except ValueError:
                return HttpResponse("Password too short!")
            else:
                return redirect("/user/signin")

        return redirect("/user/signup")
    else:
        if request.user.is_authenticated:
            return redirect("/")

        form = UserCreationForm

        return render(request, "user/signup.html", {"form": form})
```

클래스형 View 가 개발하기도 편하고 보기도 좋은거같아서 클래스형 View로 개발하고있다.

( 집가서 작성하도록 함 )
