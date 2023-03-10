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
class OperationsFileGenerator < BaseGenerator
  self.template_file = './templates/operations.mustache'

  attr_reader :action

  # @param [String | Pathname] filepath
  def initialize(filepath)
    @action = Action.new Pathname.new(filepath)
    super
  end

  def operations
    action.operations.map do |operation|
      {
        operation_group: action.operation_group,
        operation_name: operation.name,
        input_name: operation.input_name,
        output_name: operation.output_name,
        method: operation.method,
        uri: operation.path,
        description: action.description
      }
    end
  end

  def relative_path
    op_group = action.operation_group
    op_group = "_global/#{op_group}" if op_group.exclude?('.')
    "#{op_group.gsub('.', '/')}/operations.smithy"
  end
end
