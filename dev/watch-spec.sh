#!/bin/bash
cd $(dirname $0)/..
watchexec -r -w src -w spec --signal SIGTERM -- crystal spec
