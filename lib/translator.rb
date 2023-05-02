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
require_relative 'opensearch_file_generator'

# Translate legacy spec to smithy models
class Translator
  EXISTING_PATHS = %w[
    common_booleans.smithy
    common_enum_lists.smithy
    common_enums.smithy
    common_integers.smithy
    common_string_lists.smithy
    common_strings.smithy
    _global/get/operations.smithy
    _global/get/structures.smithy
    _global/get_source/operations.smithy
    _global/get_source/structures.smithy
    _global/info/operations.smithy
    _global/info/structures.smithy
    _global/search/operations.smithy
    _global/search/structures.smithy
    cat/indices/operations.smithy
    cat/indices/structures.smithy
    cat/nodes/operations.smithy
    cat/nodes/structures.smithy
    cluster/get_settings/operations.smithy
    cluster/get_settings/structures.smithy
    cluster/put_settings/operations.smithy
    cluster/put_settings/structures.smithy
    indices/create/operations.smithy
    indices/create/structures.smithy
    indices/delete/operations.smithy
    indices/delete/structures.smithy
    indices/get_settings/operations.smithy
    indices/get_settings/structures.smithy
    indices/get_mapping/operations.smithy
    indices/get_mapping/structures.smithy
    indices/put_mapping/operations.smithy
    indices/put_mapping/structures.smithy
    indices/update_aliases/operations.smithy
    indices/update_aliases/structures.smithy
    remote_store/restore/operations.smithy
    remote_store/restore/structures.smithy
  ].freeze

  def initialize(input, output, overwrite: false)
    @input = Pathname input
    @output = Pathname(output).join('model')
    @params = ParamsRepository.new
    @overwrite = overwrite
  end

  def translate(groups = nil)
    pathnames = if groups.nil?
                  @input.children
                else
                  groups.map { |basename| @input.join "#{basename}.json" }
                end
    actions = pathnames.map { |pathname| Action.new pathname }
    generate_operations actions
    generate_params actions
    # dump 'opensearch.smithy', OpensearchFileGenerator.new(actions)
  end

  private

  def relative_path(operation_group, filename)
    op_group = operation_group
    op_group = "_global/#{op_group}" if op_group.exclude?('.')
    "#{op_group.gsub('.', '/')}/#{filename}.smithy"
  end

  def generate_operations(actions)
    actions.map do |action|
      op = OperationsFileGenerator.new action
      dump relative_path(action.operation_group, 'operations'), op

      st = StructuresFileGenerator.new action
      dump relative_path(action.operation_group, 'structures'), st
    end
  end

  def generate_params(actions)
    actions.each do |action|
      @params.add_many action.query_params
      @params.add_many action.operations.map(&:path_params).flatten
    end

    dump 'common_integers.smithy',     ParamsFileGenerator.new(@params.filter_by_type(:integer), :simple)
    dump 'common_strings.smithy',      ParamsFileGenerator.new(@params.filter_by_type(:string), :simple)
    dump 'common_booleans.smithy',     ParamsFileGenerator.new(@params.filter_by_type(:boolean), :simple)
    dump 'common_enums.smithy',        ParamsFileGenerator.new(@params.filter_by_type(:enum), :enum)
    dump 'common_enum_lists.smithy',   ParamsFileGenerator.new(@params.filter_by_type(:enum_list), :enum_list)
    dump 'common_string_lists.smithy', ParamsFileGenerator.new(@params.filter_by_type(:list), :string_list)
  end

  def dump(relative_path, generator)
    return if relative_path.in?(EXISTING_PATHS)
    path = @output.join(relative_path)
    path.parent.mkpath
    path.write generator.render
  end
end
