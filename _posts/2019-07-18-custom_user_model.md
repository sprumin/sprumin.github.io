---
layout: post
title: "Seulgi Fan Page Project - Custom User Model"
date: 2019-07-18
excerpt: "Custom User Model"
tags: [python, django, model, custom user model, email login]
comments: true
---
# Custom User Model

[ 주의! 본 포스팅은 내용이 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.] 

Django 에서는 기본적으로 User Model 을 제공하고있지만 대부분의 개발자들은 Custom User Model 을 따로 만들어 사용하고 있는데 그 이유는 아래와같다.

- Django 에서 제공하는 User Model 의 필드가 제한적이라 그 이외의 데이터를 저장하고싶어서
- 비밀번호 저장 알고리즘을 변경하고싶어서
- 소셜 로그인을 사용하기 위해 ( ex. Facebook )

이 글에서 Custom User Model 을 사용하는 이유는 추가 데이터를 저장해야하고 로그인을 username 이 아닌 email 을 기본으로 할거라서 사용하게되었다.

<br>
### User Model 설정

`project/settings.py` 파일에 `AUTH_USER_MODEL = '앱이름.모델이름'` 을 삽입해준다.
이 프로젝트 같은경우에는 앱이름이 user 이고 Custom User Model 명이 User 이기 때문에 `AUTH_USER_MODEL = 'user.User'` 를 추가해주었다.
위치는 상관없지만 정 모르겠다면 제일 하단에 추가하면된다.
<br>

### AbstractBaseUser 를 상속받은 User Model 구현

AbstractBaseUser 를 상속받은 모델은 id, password, last_login 필드만 존재한다. 이를 상속해서 내가 필요로하는 필드를 추가해보았다.

```python
class User(AbstractBaseUser):
    id = models.AutoField(primary_key=True)
    email = models.EmailField(
        verbose_name="email address",
        max_length=255,
        unique=True,
    )
    username = models.CharField(max_length=32)
    photos = models.ManyToManyField(Album)
    is_superuser = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = "email"    
```

`objects = UserManager()` 는 아래서 설명하도록하고 `USERNAME_FIELD = "email"` 은 로그인, 회원가입에 아이디 대신 이메일을 사용하겠다- 라고 생각하면된다. 필요에 따라 REQUIRED_FILEDS = [] 로 반드시 입력받아야만 하는 필드를 설정할수도 있다.

<br>

### BaseUserManager 를 상속받은 UserManager 구현

Manager 는 모든 모델에 objects 라는 이름으로 포함되어있다. 쿼리셋을 날릴 때 사용되는 Model.objects.~ 가 이 objects 이다. BaseUserManager 를 상속받아 만드는 UserManager 에는 create_user, create_superuser 메소드를 구현해야한다.

```python
class UserManager(BaseUserManager):
    def create_user(self, email, username, password1, password2):
        if len(password1) < 8:
            raise ValueError("Password too short. Please set it to 8 characters or more")

        user = self.model(
            email=self.normalize_email(email),
            username=username,
        )
        user.set_password(password1)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password):
        user = self.model(
            email=self.normalize_email(email),
        )
        user.set_password(password)

        user.is_superuser = True
        user.save(using=self._db)
        return user
```

단순히 유저를 생성하는 메소드, 관리자계정을 생성하는 메소드이다. 이 이외에도 사용하고싶은 메소드가 있다면 추가하면된다.

이렇게 구현된 UserManager 를 위 Custom User Model 에서 사용하겠다고 선언하는 부분이 위에서 작성한 `objects = UserManager()` 이다.

<br>

테스트는 `python manage.py createsuperuser` 명령어를 실행했을때 username 이 아닌 email 을 입력받으면 성공이다.
`USERNAME_FIELD` 를 어떻게 설정했는지에 따라 다를 수 있다.


이렇게 Custom User Model 을 구현해보았다. 다음 포스트에서는 회원가입, 로그인 로그아웃등 유저 이벤트에 대해 다뤄볼예정이다.