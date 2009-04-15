#!/usr/bin/env ./script/runner

puts JobTweet.delete_all(["created_at <= ?", 30.days.ago])
