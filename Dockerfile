FROM docker.elastic.co/logstash/logstash:8.11.0

# Install JDBC output plugin
RUN logstash-plugin install logstash-output-jdbc
