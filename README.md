General documentation for [BOSH](https://bosh.io/). We render these docs with [mkdocs](https://www.mkdocs.org/) using a [slightly-adapted](theme) [material](https://github.com/squidfunk/mkdocs-material) theme, and you can find a rendered version of these docs at [bosh.io/docs](https://bosh.io/docs/).


## Development

For local development, use Docker and preview on [localhost:8000](http://localhost:8000/)...

    docker run --rm -it -p 8000:8000 -v "${PWD}:/docs" squidfunk/mkdocs-material:2.7.2
