# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require_relative 'base_generator'
require_relative 'action'

# Generator for operations.smithy
class OpensearchFileGenerator < BaseGenerator
  self.template_file = './templates/opensearch.mustache'

  # @param [Array<Action>] actions
  def initialize(actions)
    @action = actions
    super
  end

  def operations
    actions.map(&:operations).flatten.map(&:name).sort.map { |name| { name: } }
  end
end
