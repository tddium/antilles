# Antilles

## Overview

Antilles sets up a stub HTTP server using mimic and exposes a simple interface
to configure the server.  Antilles is meant to work with aruba to make it easier
to test command line tools that communicate with Web APIs. 

## Installation

Antilles works best with cucumber, but it can be used with any testing tool.

1. Install the gem:

      gem install antilles

   or use bundler:

      group :test do
        gem :antilles
      end

2. Set up environment:

      # features/support/antilles.rb
      require 'antilles/cucumber'

      Antilles.configure do |server|
        server.port = 9876   # defaults to 8080
        server.log = STDOUT  # defaults to nil for no logging
      end

Requiring `antilles/cucumber` will automatically start a server before all
Scenarios tagged `@mimic`, and tear down the server when the test exits.

## Usage

Antilles can be configured to do anything mimic can do, but the basic mode of
operation is to `install` stubs:

    Given /^creating a membership fails with: (.*)$/ do |error|
      user="a@b.com"
      Antilles.install(:post, "/memberships/#{user}", {:status=>1, :explanation=>error}, :code=>409)
    end
