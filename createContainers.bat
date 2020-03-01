@echo off
docker login
echo create containers.
echo create  database container

docker run --name mysql -e MYSQL_ROOT_PASSWORD=jes -p 3306:3306 -d mysql
docker run  -itd  --name   backend   tomcat
docker run  -itd   --name frontend   -d   node
docker network remove network5 
docker network create network5 
docker network connect  network5 mysql
docker network connect  network5 backend
docker network connect  network5 frontend
git clone https://github.com/anthau/frontOrient.git
git clone  https://github.com/anthau/oBackEnd.git
docker cp oBackEnd/oBackEnd.war backend:/usr/local/tomcat/webapps
docker cp frontOrient/ frontend:/

docker run -it -d -p 81:81 --network=network5  --name proxy nginx
docker cp firewall.txt  proxy:/etc/nginx/conf.d/default.conf 
docker exec proxy nginx -s reload

docker exec -i frontend bash -c "cd  /frontOrient && npm install"
docker exec -i frontend bash -c "cd  /frontOrient && npm audit fix"
docker exec -i frontend bash -c "cd  /frontOrient && npm start"