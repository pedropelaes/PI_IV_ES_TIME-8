javac -cp "libs/*" *.java
java -Djavax.net.ssl.trustStore=/usr/lib/jvm/temurin-17-jdk/lib/security/cacerts -Djavax.net.ssl.trustStorePassword=changeit -cp ".:libs/*" Servidor