---
title: "Minimal Mistakes 적용기"
date: 2025-01-10 16:00:00 +0900
toc: true
toc_sticky: true
tags:
    - github
    - github pages
    - jekyll
    - minimal mistakes
---

시즌 525번째 "기술블로그 시작해야지"

## 개요

매년 이직 시즌이 찾아올 때 마다 기술블로그를 써야겠다는 생각을 한다.

그렇다 진짜 생각만 했다.

이번에 시작안하면 이번 생에는 안할 것 같아서 세팅부터 시작했다.

## github pages

velog, tistory, medium, notion 등 고민을 많이 했지만 github pages로 선택하였다.

각자 장단점이 있지만 github pages를 선택한 이유는 그나마 익숙해서다.

이전에 테마 설정해놓은게 일부 남아있기도 했고, 다른 플랫폼은 처음부터 시작해야해서 익숙한 플랫폼으로 골랐다.

> 하지만 첫 글을 쓰기보다 세팅하는데 시간이 더 오래 걸리게 되었다는..

## Minimal Mistakes

심플하다. 해당 테마를 선택한 이유다.

화려한걸 별로 좋아하지 않아서 여백이 좀 있고 폰트가 심플한 테마를 찾는게 목표였는데 마침 Minimal Mistakes 테마가 보여서 바로 가져왔다.

Minimal Mistakes 공식 가이드도 잘되어 있지만, 사용하는 사람들도 많아서 그런지 폰트 설정이나 세부 디테일 수정에 있어서 참고할 수 있는 글들이 많았다.

### Ruby 와 Jekyll 설치

[Ruby+Devkit](https://rubyinstaller.org/downloads/) 에서 x86 으로 설치해야한다.
> jekyll이 32비트라서 x86 설치

이후 하기 명령어들을 실행해주었다.

```bash
# jekyll 다운로드
gem install jekyll

# bundler 다운로드
gem install bundler

# 로컬 서버 구동
bundle exec jekyll serve
```

### bundler, jekyll 설치 오류

```bash
MSYS2 seems to be unavailable Verify integrity of msys2-x86_64-20190524.exe ... 
```

이런 오류가 발생했었다.

`ridk install` 이라는 명령어를 실행하라는 안내 문구를 반환하기에 시도했지만 제대로 설치가 되지 않아서 삽질하게 되었다.

[MSYS2](https://www.msys2.org/) 여기서 msys2...exe 파일을 다운로드 한 뒤 설치하자.

설치 후 `ridk install` 명령어 실행 후 `3` 을 선택해야 devkit 까지 설치되어 오류가 발생하지 않는다.

이제 다시 설치하면 정상적으로 진행된다.

## 마치며

그래도 블로그 설정하고 글 하나 쓰고 나니까 나름 이뻐보인다.

하루 하나는 아니더라도 주에 한두개씩 쓰다보면 나중에 다시 읽어볼만한 내용들이 있겠지