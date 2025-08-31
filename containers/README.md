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
