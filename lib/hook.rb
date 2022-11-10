# frozen_string_literal: true
HOOK_APP = "Hookmark"

require 'hook/version'
require 'tty-which'
require 'shellwords'
require 'cgi'
require 'gli'
require 'hook/prompt'
require 'hook/string'
require 'hook/hookapp'
require 'hook/hooker'
require 'hook/markdown_document_listener'
