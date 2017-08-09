# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

GOBIN = main
OUT = function.zip

all: go js
	zip -FS -r $(OUT) $(GOBIN) node_modules index.js package.json -x *build*

go: FORCE
	GOARCH="amd64" GOOS="linux" go build -tags netgo $(GOBIN).go

js: FORCE
	npm install --save local_modules/execer

localgo: FORCE
	go build $(GOBIN).go

clean: FORCE
	rm -rf $(GOBIN) $(OUT) node_modules

test: js localgo
	node testserver.js

FORCE:

# define APPNAME and STAGEBUCKET
# https://cloud.google.com/sdk/gcloud/reference/beta/functions/deploy
deploy: all
	rm -rf build.deploy # clean
	unzip -u $(OUT) -d build.deploy
	cp -r local_modules build.deploy/ #  ¯\_(ツ)_/¯
	cd build.deploy; gcloud beta functions deploy $(APPNAME) --trigger-http --stage-bucket=$(STAGEBUCKET)
	rm -rf build.deploy # clean
