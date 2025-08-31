# FROM chapel/chapel:latest
FROM ubuntu:24.04

RUN apt-get update -y && apt-get install -y wget
RUN wget https://github.com/chapel-lang/chapel/releases/download/2.5.0/chapel-2.5.0-1.ubuntu24.arm64.deb
RUN apt-get install -y ./chapel-2.5.0-1.ubuntu24.arm64.deb

ENTRYPOINT [ "/bin/bash" ]
