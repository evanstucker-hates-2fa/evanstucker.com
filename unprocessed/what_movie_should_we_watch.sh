#!/bin/bash

jq -r '.[] | select(.review == null) | select(.binary_rating == null) | .title' movies.json
