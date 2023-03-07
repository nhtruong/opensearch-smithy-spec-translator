# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require 'mustache'
require 'active_support/all'

# Base Mustache Generator
class BaseGenerator < Mustache
  self.template_path = './templates'

  def license_header
    Pathname('./templates/license_header.txt').read
  end
end
