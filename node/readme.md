# Symbiote node tools

## Build

`docker build -t symbiote/node .`

## Run

Exposing port 4200, some projects will want to do this differently to match
their internal webpack configs

```
docker run -it --rm -v $(pwd):/tmp -w /tmp -p 4200:4200 -u `id -u`:`id -g` symbiote/node
```

To run the inner binaries directly, simply pass as a parameter 

```
docker run -it --rm -v $(pwd):/tmp -w /tmp -p 4200:4200 -u `id -u`:`id -g` symbiote/node yarn start
```
