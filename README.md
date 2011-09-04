# Antilles

## Overview

Antilles forks a stub HTTP server using
[mimic](https://github.com/lukeredpath/mimic) and exposes a simple interface to
configure the server.  Antilles is meant to work with
[aruba](https://github.com/cucumber/aruba) to make it easier to
test command line tools that communicate with Web APIs.

Read this [blog post](http://blog.tddium.com/2011/09/04/antilles-testing-clis-that-use-web-services/) for our motivation.

## Installation

Antilles works best with cucumber and aruba, but it can be used with any testing tool.

### Install the gem:

      gem install antilles

   or use bundler:

      group :test do
        gem :antilles
      end

### Set up environment, for example with cucumber:

      # features/support/antilles.rb
      require 'antilles/cucumber'

      Antilles.configure do |server|
        server.port = 9876   # defaults to 8080
        server.log = STDOUT  # defaults to nil for no logging
      end

Requiring `antilles/cucumber` will automatically start a server before all
Scenarios tagged `@mimic`, clear stubs between tests, and tear down the server
when the test exits.  Look at [cucumber.rb]
(https://github.com/tddium/antilles/blob/master/lib/antilles/cucumber.rb) if you
need to customize this behavior.

## Usage

Antilles can be configured to do anything mimic can do, but the basic mode of
operation is to `install` stubs:

    Given /^creating a membership fails with: (.*)$/ do |error|
      user="a@b.com"
      Antilles.install(:post, "/memberships/#{user}", {:status=>1, :explanation=>error}, :code=>409)
    end
