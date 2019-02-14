---
layout: post
title: "LoveSeulgi Project - Google Image Crawling with Selenium"
date: 2019-02-14
excerpt: "Python google image crawling with selenium"
tags: [python, chromedriver, headless, crawl, selenium, regex]
comments: false
---

# Python Google Image Crawling with Selenium

[ 주의! 본 포스팅은 내용이 정확하지 않을 수 있습니다. 수정할 부분은 피드백해주시면 감사드리겠습니다.]

레드벨벳 슬기 사진을 모으기위해 크롤러를 제작하기로 했다.

이미지를 어디서 크롤링할지 고민하다가 고른게 인스타그램이었는데 인스타그램 특성상 태그가 여러개 겹쳐서 슬기말고도 다른 연예인 사진도 같이 크롤링 되어버렸다.

그 뒤 인스타그램 크롤러를 날리고... ( 주륵 ) 정확성이 높은 구글 이미지를 사용하기로했다.

그래서 requests 로 html 을 긁어온 후 정규표현식으로 이미지들만 걸러서 저장했는데 문제가 생겼다.. 뒤늦게 알았지만 가져온 이미지들이 thumbnail 이었다. 그래서 그런지 이미지 화질이 많이 좋지 않았다. ( 충격받고 또 크롤러를 날렸다 )

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/google_thumbnail.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/google_thumbnail.png"></a>
</figure>

그래서 더 좋은 화질의 이미지를 가져오기위해서는 2번 이미지를 크롤링해야하는데 1번을 눌러야 2번이 html 상에 나타난다. 그래서 selenium 으로 하나하나 클릭해서 크롤링하기로했다. 더 쉽고 좋은 방법이 있다면 댓글 남겨주시길바랍니다.





### Selenium 설치하기

Selenium 을 사용하기위해 Selenium 과 Chromedriver 를 설치해야한다. ( Phantom.js 도 가능)

- Selenium : `pip install selenium `

- Chromedriver :  [Chromedriver](http://chromedriver.chromium.org/downloads) 에 들어가서 설치된 크롬 버전과 운영체제에 맞게 설치하여 사용하면된다.

  - 설치된 크롬버전 확인법

    크롬 우측상단  : 버튼 -> 도움말 -> Chrome 정보 에서 확인할 수 있다. 





### Selenium 실행해보기

Selenium 과 Chromedriver 를 설치했다면 이제 사용해보자.

```python
from selenium import webdriver


driver = webdriver.Chrome("chromedriver")
driver.implicitly_wait(3)

driver.get("https://www.naver.com")
```

"chromedriver" 위치에는 현재 chromedriver.exe 가 설치되어있는 경로를 입력해주면된다. 나는 프로젝트 폴더에 위치해있어서 파일명만 적어주었다.

