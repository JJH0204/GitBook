# Docker Compose 워드프레스 실습

## Code Block

{% code title="docker-compose.yml" %}
```yml
services:
  wordpress:
    image: wordpress:5.0.3-apache
    ports:
      - "80:80"
    depends_on:
      - mariadb
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    restart: always

  mariadb:
    image: mariadb:latest
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: word123pass456
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress
    restart: always

volumes:
  db_data: {}
```
{% endcode %}

\[mission 1]\
wordpress 5.x 이미지, 컨테이너 실행\
wordpress 머신에 웹페이지 제작 후 정상 접속 확인\
변경 사항을 포함한 이미지 생성 후 Docker Hub 업로드 후 확인

* docker-compose.yml 파일을 통해 다수의 컨테이너 설정을 한번에 정의
* docker compose up -d "docker-compose.yml 설정에 따라 컨테이너 실행"

docker image tag mariadb:latest krjaeh0/dockerhub\_test:mariadb\
docker image tag wordpress:5.0.3-apache krjaeh0/dockerhub\_test:wordpress\
docker image push krjaeh0/dockerhub\_test:mariadb\
docker image push krjaeh0/dockerhub\_test:wordpress

docker images

이미지 이름 확인

app 을 직접 도커hub에 업로드해 관리하는 것은 비효율적인 것 같다.\
app 구동환경(OS)에 시스템을 구축하고 OS를 Hub에 업로드해 관리하자

### 참고 링크

dxLgULur: Excalidraw/Docker\_실습.md#Code Block
