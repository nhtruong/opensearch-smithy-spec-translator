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
    "#{action.operation_group.gsub('.', '_').camelcase}QueryParams"
  end

  def query_params
    action.query_params.map do |param|
      {
        name: param.name,
        type: param.smithy_name
      }
    end
  end

  def input_structures
    action.operations.map do |operation|
      {
        structure_name: operation.input_name,
        common_query_structure:,
        path_params: operation.path_params&.map { |param| { name: param.name, type: param.smithy_name } }
      }
    end
  end

  def output_structures
    action.operations.map do |operation|
      {
        structure_name: operation.output_name
      }
    end
  end
end
