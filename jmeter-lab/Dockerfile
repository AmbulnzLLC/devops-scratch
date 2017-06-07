FROM openjdk:9-jdk
MAINTAINER jake@jakebladt.com

WORKDIR /jmeter
COPY . /jmeter
CMD ["wget", "http://apache.claz.org/jmeter/binaries/apache-jmeter-3.2.zip"]

CMD ["/jmeter/run.sh"]
