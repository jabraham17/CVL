## Build

```bash
docker build . -t cvl/cvl:latest -f containers/Dockerfile
```

## Run

```bash
docker run -w="$(pwd)" -v"$(pwd)":"$(pwd)":z -it --rm cvl/cvl:latest
```


Use chapel/chapel directly

```bash
docker run -w="$(pwd)" -v"$(pwd)":"$(pwd)":z -it --rm chapel/chapel:latest
```

Test x86 or ARM64 when not on that architecture

```bash
docker run --platform=linux/amd64 -w="$(pwd)" -v"$(pwd)":"$(pwd)":z -it --rm chapel/chapel:latest
docker run --platform=linux/arm64 -w="$(pwd)" -v"$(pwd)":"$(pwd)":z -it --rm chapel/chapel:latest
```
