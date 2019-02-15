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

그래서 requests 로 html 을 긁어온 후 정규표현식으로 이미지들만 걸러서 저장했는데 문제가 생겼다.

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/google_thumbnail.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/google_thumbnail.png"></a>
</figure>

내가 크롤러로 가져온 이미지는 1번 이미지였다. 1번 이미지는 Thumbnail 이라서 화질이 굉장히 안좋았다.

크롤러를 다시 짜러가자.. 2번 이미지를 가져와야한다.. 그런데 html 을 긁어와보니 2번 이미지가 없네?

requests 로 못 가져오는걸보니 자바스크립트가 렌더링 된 후에 생기는 태그 같다.

그래서 어쩔 수 없이 Selenium 을 사용해서 이미지들을 긁어오기로 했다.



### Selenium 설치하기

Selenium 을 사용하기위해 Selenium 과 Chromedriver 를 설치해야한다. ( Phantom.js 도 가능)

- Selenium : `pip install selenium `
- Chromedriver :  [Chromedriver](http://chromedriver.chromium.org/downloads) 에 들어가서 설치된 크롬 버전과 운영체제에 맞게 설치하여 사용하면된다.
- 설치된 크롬버전 확인법
  - 크롬 우측상단  : 버튼 -> 도움말 -> Chrome 정보 에서 확인할 수 있다. 



### Selenium 실행해보기

Selenium 과 Chromedriver 를 설치했다면 이제 사용해보자. 

```python
from selenium import webdriver

driver = webdriver.Chrome("chromedriver")
driver.get("https://www.google.co.kr/search?q=레드벨벳슬기&tbm=isch")
driver.implicitly_wait(3)

print(driver.page_source)

driver.quit()
```
- `webdriver.Chrome()` : chromedriver.exe 가 설치되어있는 경로를 설정해준다.
  - 나는 Chromedriver.exe 가 프로젝트 폴더에 위치해있어서 파일명만 적어주었다.
- `driver.get()` : 접속하고자하는 페이지의 url 을 삽입해준다.
- `driver.implicitly_wait()` : 페이지가 다 로딩될때까지 기다리는 시간을 지정해준다.
- `driver.page_source` : 현재 Chromedriver 로 띄운 페이지의 html 소스 코드를 볼 수 있다.

사용이 끝나면 `driver.quit()` 으로 Chromedriver 창을 닫아준다.



### 이미지 파싱하기

정규표현식을 사용하여 이미지, 출처, 제목을 파싱하도록하자.

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/find_image_info.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/find_image_info.png"></a>
</figure>

위 이미지에서 파싱할 데이터는 아래와 같다.

- ru : 출처
- ou : 이미지링크
- pt : 제목



정규표현식으로 파싱한 후 데이터를 출력하는 소스를 추가해보자.

```python
from selenium import webdriver

import re

regex = r"\"ou\":\"(.*?)\".*?\"pt\":\"(.*?)\".*?\"ru\":\"(.*?)\""

driver = webdriver.Chrome("chromedriver")
driver.get("https://www.google.co.kr/search?q=레드벨벳슬기&tbm=isch")
driver.implicitly_wait(3)

images_info = re.findall(regex, driver.page_source)
for info in images_info:
    print(info)

driver.quit()
```

데이터는 [(이미지링크, 제목, 출처), (이미지링크, 제목, 출처)...] 형태로 저장되어 출력된다. 

파싱까지 성공했으니 끝난 것 같지만 여기서 끝난것이 아니라 몇가지 설정을 더 해주어야한다.



### 구글 이미지 추가 로딩시키기

- 단어 선택이 부정확했을 수 있습니다.

구글 이미지엔 수많은 이미지들이 올라와있지만 위 소스를 실행해보면 30-40 개의 이미지밖에 가져오지 못한다.

직접 들어가보면 알겠지만 스크롤을 아래로 내릴수록 이미지들이 추가로 로딩되는것을 볼 수 있다.

그래서 한번에 많은 이미지를 크롤링하기위해 Selenium 을 이용해서 스크롤을 최대한 아래로 내려줄것이다.

```python
from selenium import webdriver

import re

regex = r"\"ou\":\"(.*?)\".*?\"pt\":\"(.*?)\".*?\"ru\":\"(.*?)\""

driver = webdriver.Chrome("chromedriver")
driver.get("https://www.google.co.kr/search?q=레드벨벳슬기&tbm=isch")
driver.implicitly_wait(3)

last_height = driver.execute_script("return document.body.scrollHeight")
SCROLL_PAUSE_TIME = 0.5

while True:
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    time.sleep(SCROLL_PAUSE_TIME)
    new_height = driver.execute_script("return document.body.scrollHeight")
 
    if new_height == last_height:
        break

    last_height = new_height
    
images_info = re.findall(regex, driver.page_source)
for info in images_info:
    print(info)

driver.quit()
```

- 요약 ( `scroll_pause_time` 은 스크롤이 내려가면서 이미지가 추가 로딩되는걸 눈으로 보기위해 설정함 )

1. `last_height` 에 현재 페이지의 높이 저장
2. scroll 을 `last_height` 까지 내린후 `new_height` 에 현재 페이지의 높이를 저장
3. 여기서 두 가지 경우로 나뉜다
   1. `last_height` 와 `new_height` 의 값이 같은 경우
      1. 더 이상 스크롤 할 페이지가 없으므로 루프 종료
   2. `last_height` 와 `new_height` 의 값이 다른 경우
      1. 아직 스크롤 할 페이지가 남아있다는 뜻
      2. `last_height` 에 `new_height` 값을 저장하고 다시 2번으로 돌아가 값이 같아질 때 까지 반복



그리고 스크롤을 내리다보면 아래와 같이 버튼이 하나 나온다.

<figure>
    <a href="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/결과더보기.png">
        <img src="https://raw.githubusercontent.com/sprumin/sprumin.github.io/master/assets/img/post_image/결과더보기.png"></a>
</figure>

자동 스크롤을 막으려고 해놓은건지... 잘 모르겠지만 저걸 눌러줘야 추가로 로딩이 된다.

버튼이 있는지 없는지 검사하고 있으면 클릭해주는 소스만 `time.sleep(SCROLL_PAUSE_TIME)` 아래에 추가해주면 된다.

```python
try:
    element = driver.find_elements_by_id("smb")[0]
    element.click()
except:
    pass
```



크롤러를 다 짜고 보니 저장할 모델을 생성하지 않았다는걸 뒤 늦게 알았다..

순서가 이상하지만 다음에는 Django Model 을 생성하고 크롤링한 데이터를 저장시켜보겠다.



