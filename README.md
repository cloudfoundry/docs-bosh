General documentation for [BOSH](https://bosh.io/). We render these docs with [mkdocs](https://www.mkdocs.org/) using a [slightly-adapted](theme) [material](https://github.com/squidfunk/mkdocs-material) theme, and you can find a rendered version of these docs at [bosh.io/docs](https://bosh.io/docs/).

## Development

For local development:

  * Clone this repo.
  * Initialize the submodule (external/bpm-release).
  * Use [Docker](https://docs.docker.com/install/) start a local server.

```shell
git clone https://github.com/cloudfoundry/docs-bosh.git
cd docs-bosh

git submodule update --init --recursive

docker run --rm -it -p 8000:8000 -v "${PWD}:/docs" squidfunk/mkdocs-material:2.7.2
```

You can then make changes in a text editor, and refresh in a local browser at [localhost:8000](http://localhost:8000/).
