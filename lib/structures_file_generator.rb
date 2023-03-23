# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

# Generator for structures.smithy
class StructuresFileGenerator < BaseGenerator
  self.template_file = './templates/structures.mustache'
  attr_reader :action

  # @param [Action] action
  def initialize(action)
    @action = action
    super
  end

  def common_query_structure
    "#{action.operation_group.gsub('.', '_').camelcase}_QueryParams"
  end

  def common_body_structure
    return unless action.with_body?
    "#{action.operation_group.gsub('.', '_').camelcase}_BodyParams"
  end

  def query_params
    action.query_params.map do |param|
      {
        name: param.original_name,
        type: param.smithy_name,
        unique_description?: param.unique_description?,
        description: param.documentation,
        unique_default?: param.unique_default?,
        default: param.default_value,
        required?: param.spec.required,
        _blank_line: param.name != action.query_params.last.name
      }
    end
  end

  def input_structures
    action.operations.map do |operation|
      {
        structure_name: operation.input_name,
        common_query_structure:,
        with_body: operation.with_body?,
        path_params: operation.path_params&.map do |param|
                       { name: param.original_name,
                         type: param.smithy_name,
                         _blank_line: param.name != operation.path_params.last.name }
                     end
      }
    end
  end

  def output_structure
    action.operations.first.output_name
  end
end
