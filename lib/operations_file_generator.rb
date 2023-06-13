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

  # @param [Action] action
  def initialize(action)
    @action = action
    super
  end

  def operations
    action.operations.map do |operation|
      {
        operation_group: action.operation_group,
        readonly: operation.method == 'GET',
        idempotent: operation.method.in?(%w[PUT DELETE]),
        delete_with_body: operation.delete_with_body?,
        operation_name: operation.name,
        input_name: operation.input_name,
        output_name: operation.output_name,
        method: operation.method,
        uri: operation.path,
        description: action.description,
        deprecated: operation.deprecated,
        extensions: extensions(operation),
        _blank_line: operation != action.operations.last
      }
    end
  end

  def extensions(operation)
    { 'operation-group': action.operation_group,
      'version-added': '1.0' }
      .merge(deprecation_info(operation)).compact.map { |k, v| { key: k, value: v } }
  end

  def deprecation_info(operation)
    return {} unless operation.deprecation.is_a? OpenStruct
    { 'deprecation-message': operation.deprecation.description,
      'version-deprecated': '1.0',
      'ignorable': operation.deprecation.ignorable }
  end
end
