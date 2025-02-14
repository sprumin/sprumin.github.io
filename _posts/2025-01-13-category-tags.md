---
title: "[Github Pages] Tags! Instead of category"
date: 2025-01-13 12:00:00 +0900
toc: true
toc_sticky: true
tags:
    - github
    - github pages
    - jekyll
    - minimal mistakes
---

Tags 로 post를 관리하고 싶은데 쉽지 않아

## 개요

기술블로그 관련해서 찾아보다가 Kakao Tech Blog 게시글 형태가 깔끔해보였다.

category를 별도로 구현하지 않고, tag 를 나열해서 해당 tag를 클릭하면 관련 post만 보이도록 하는 구조였다.

문제는 내가 github pages 구조에 익숙하지 않다는 것..

그래서 기본적으로 지원하는 기능을 먼저 찾아보고 이후에 코드를 뜯어보려한다.

## Tags 추가

기본 템플릿은 페이지 우측 상단에 Home, About, Category, Tags 메뉴가 추가되어있다.

난 Category, Tags 를 제거하고, 왼쪽 Sidebar에 Tag 리스트를 추가하려고 한다.

### Tags.md

Tags 메뉴, 혹은 각 태그를 클릭했을 때 redirect 될 페이지를 만들어야한다.

`_pages/tags.md` 경로를 생성하여 아래 내용을 입력해주면된다.

```markdown
---
title: "Tags"
layout: tags
permalink: /tags/
---
```

해당 페이지를 어떤식으로 커스텀이 가능한지는 공부하면서 알아가야지..

### sidebar에 tags 노출

더 간단한 기능이 있는지 알아봐야겠지만 다른 블로그를 참고하여 `_includes/sidebar.html` 에 아래와 같이 작업했다.

```html
{% raw %}
<div class="sidebar__tags">
    <h3>Tags</h3>
    <ul>
    {% assign sorted_tags = site.tags | sort %}
    {% for tag in sorted_tags %}
        <li>
        <a href="/tags/#{{ tag[0] | slugify }}">{{ tag[0] }} ({{ tag[1].size }})</a>
        </li>
    {% endfor %}
    </ul>
</div>
{% endraw %}
```

위치는 sidebar div 최하단에 추가하면 되고, 템플릿에 지원하는 문법이 많아 활용하기 좋다.

### Post에 tag 추가

해당 태그들을 별도로 관리하는 형식을 사용하지 않았다.

Post에 태그를 할당하면, 해당 태그들이 jekyll에서 전역변수로 수집되며 각 템플릿에서 호출하여 사용하는 형태인것 같다.

Posts 머리말에 아래 내용을 추가해주면 된다.

```markdown
tags:
    - github
    - github pages
    - ruby
    - minimal mistakes
```

## 마치며

까먹지 않으려고 기록한 내용이라 부정확한 부분도, 더 간단하게 변경할 방법도 있을 것이다.

현재 tags 페이지를 열어보면 모든 태그가 나열되어 있고, 각 태그별로 중복된 post도 노출되어 원하는 스타일의 페이지가 아닌 상황이다.

sidebar에서 클릭한 tag에 대한 포스트만 나열되도록 수정해보려한다.




