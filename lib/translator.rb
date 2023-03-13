# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require_relative 'params_repository'
require_relative 'params_file_generator'
require_relative 'operations_file_generator'
require_relative 'structures_file_generator'

# Translate legacy spec to smithy models
class Translator
  def initialize(input, output)
    @input = Pathname input
    @output = Pathname output
    @params = ParamsRepository.new
  end

  def translate(groups = nil)
    pathnames = if groups.nil?
                  @input.children
                else
                  groups.map { |basename| @input.join "#{basename}.json" }
                end
    actions = pathnames.map { |pathname| Action.new pathname }
    generate_operations actions
    generate_params_files actions
  end

  private

  def relative_path(operation_group, filename)
    op_group = operation_group
    op_group = "_global/#{op_group}" if op_group.exclude?('.')
    "#{op_group.gsub('.', '/')}/#{filename}.smithy"
  end

  def generate_operations(actions)
    folder = @output.join('model')
    actions.map do |action|
      op = OperationsFileGenerator.new action
      dump folder, relative_path(action.operation_group, 'operations'), op

      st = StructuresFileGenerator.new action
      dump folder, relative_path(action.operation_group, 'structures'), st
    end
  end

  def generate_params_files(actions)
    actions.each do |action|
      @params.add_many action.query_params
      # action.operations.each { |operation| @params.add_many operation.path_params }
    end

    folder = @output.join('model')
    dump folder, 'common_integers.smithy', ParamsFileGenerator.new(@params.filter_by_type(:integer), :simple)
    dump folder, 'common_strings.smithy',  ParamsFileGenerator.new(@params.filter_by_type(:string), :simple)
    dump folder, 'common_booleans.smithy', ParamsFileGenerator.new(@params.filter_by_type(:boolean), :simple)
    dump folder, 'common_lists.smithy',    ParamsFileGenerator.new(@params.filter_by_type(:list), :list)
    dump folder, 'common_enums.smithy',    ParamsFileGenerator.new(@params.filter_by_type(:enum), :enum)
  end

  def dump(folder, relative_path, generator)
    # TODO: Handle Collisions with existing files
    path = folder.join(relative_path)
    path.parent.mkpath
    path.write generator.render
  end
end
