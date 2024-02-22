#!/bin/bash

jq -r '.[] | select(.review == null) | .title' movies.json
