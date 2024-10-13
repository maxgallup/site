# init:
#     git submodule update --remote --recursive
#     cd themes/duckquill && git checkout v4.6.0
#     cd ../..


all: build
    zola serve

build:
    zola build


