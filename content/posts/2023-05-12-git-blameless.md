---
title: "git blameless"
date: 2023-05-12T19:40:28-07:00
draft: false
---
What if there was a "git blameless" command that gave each author a forgiving pseudonym? 😅 
```
$ git blameless main.tf 
5ed5fcab (well_intentioned_individual        2021-11-17 21:53:27 -0800  1) resource "aws_autoscaling_group" "example" {
e3e56dcd (no_time_to_do_this_the_right_way    2022-12-31 13:01:54 -0800  7)      key                 = tag.key
27096f14 (still_learning        2022-02-18 18:10:06 -0800  8)  for_each = {
```
