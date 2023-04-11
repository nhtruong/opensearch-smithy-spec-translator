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
class Parameter
  attr_reader :spec, :original_name, :comma_separated_list, :param_type

  delegate :type, :description, :default, to: :spec

  # @param [String] name
  # @param [OpenStruct] spec
  def initialize(name, spec, operation_group, param_type = 'query')
    @param_type = param_type
    spec.type = 'string' if spec.type == 'number|string'
    spec.type = 'integer' if spec.type == 'number'
    spec.type = 'list' if spec.description&.starts_with?('A comma-separated')
    @original_name = name
    @spec = spec
    @operation_group = operation_group
    @deprecation = spec.deprecated
    capture_default
  end

  def pattern
    return '^([0-9]+)(?:d|h|m|s|ms|micros|nanos)$' if spec.type == 'time'
    return enum_path_pattern if spec.options.present? && param_type == 'path'
    return '^[^_][\\\\d\\\\w-*]*$' if param_type == 'path'
    nil
  end

  def enum_path_pattern
    members = spec.options.map { |option| Regexp.escape(option) }.join('|')
    spec.type == 'list' ? "^((#{members}),)*(#{members})$" : "^(#{members})$"
  end

  def name
    return @name if @name
    return @name = "#{@operation_group.gsub('.', '_')}_#{@original_name}" if @original_name.in? %i[metric dry_run]
    return @name = "#{@original_name}_#{spec.type}" if @original_name == :refresh
    return @name = "#{@original_name}_#{spec.default}" if @original_name == :wait_for_completion
    return @name = 'with_version' if @original_name == :version && spec.type == 'boolean'
    return @name = 'bulk_timeout' if @original_name == :timeout && spec.description.starts_with?('Time each individual bulk')
    return @name = 'scroll_ids' if @original_name == :scroll_id && spec.type == 'list'
    return @name = 'indices' if @original_name == :index && spec.type == 'list'
    return @name = 'repositories' if @original_name == :repository && spec.type == 'list'
    return @name = 'routings' if @original_name == :routing && spec.type == 'list'
    return @name = 'snapshots' if @original_name == :snapshot && spec.type == 'list'
    return @name = 'document_id' if @original_name == :id && spec.description.starts_with?('Document ID')
    return @name = 'script_id' if @original_name == :id && spec.description == 'Script ID'
    return @name = 'pipeline_id' if @original_name == :id && spec.description == 'Pipeline ID'
    return @name = 'pipeline_ids' if @original_name == :id && spec.description.starts_with?('Comma-separated list of pipeline ids')
    return @name = 'search_template_id' if @original_name == :id && spec.description == 'The id of the stored search template'
    return @name = 'alias_name' if @original_name == :name && spec.description.starts_with?('The name of the alias')
    return @name = 'template_name' if @original_name == :name && spec.description.starts_with?('The name of the template')
    return @name = 'template_names' if @original_name == :name && spec.description.starts_with?('Comma-separated names of the index templates')
    return @name = 'component_template_names' if @original_name == :name && spec.description.starts_with?('The Comma-separated names of the component templates')
    return @name = 'setting_names' if @original_name == :name && spec.description.starts_with?('Comma-separated list of settings')
    return @name = 'alias_names' if @original_name == :name && spec.description.starts_with?('Comma-separated list of alias names')
    return @name = 'stream_names' if @original_name == :name && spec.description.starts_with?('Comma-separated list of data streams')
    return @name = 'stream_name' if @original_name == :name && spec.description.starts_with?('The name of the data stream')
    return @name = 'index_names' if @original_name == :name && spec.description.starts_with?('Comma-separated list of names or wildcard expressions')
    return @name = 'index_name' if @original_name == :name && spec.description.starts_with?('The name of the index (it must be a concrete index name)')
    return @name = 'df_explain' if @original_name == :df && spec.description.starts_with?('The default')
    return @name = 'df_explain_snapshot' if @original_name == :ignore_unavailable && spec.description.starts_with?('Whether to ignore unavailable snapshots')
    return @name = 'stat_fields' if @original_name == :fields && spec.description.ends_with?('(supports wildcards)')
    return @name = 'cluster_health_level' if @original_name == :level && spec.description == 'Specify the level of detail for returned information'
    return @name = 'indicies_stat_level' if @original_name == :level && spec.description == 'Return stats aggregated at cluster, index or shard level'
    return @name = 'nodes_stat_level' if @original_name == :level && spec.description == 'Return indices stats aggregated at index, node or shard level'
    return @name = 'search_type_multi' if @original_name == :search_type && spec.options.size == 4
    return @name = 'snapshots_count' if @original_name == :snapshots && spec.type == 'integer'
    return @name = 'document_type' if @original_name == :type && spec.type == 'string'
    return @name = 'sample_type' if @original_name == :type && spec.type == 'enum'
    return @name = 'sample_type' if @original_name == :type && spec.type == 'enum'
    @name = @original_name.to_s
  end

  def repo_id
    "#{param_type}_#{name}"
  end

  def param_name
    return "query_#{original_name}" if param_type == 'query'
    original_name.to_s
  end

  def smithy_name
    return "path_#{name}".camelcase if param_type == 'path'
    name.to_s.camelcase
  end

  def smithy_type
    return 'string' if param_type == 'path'
    return 'string' if type == 'time'
    return 'enum_list' if type == 'list' && spec.options.present?
    spec.type
  end

  def unique_description?
    return true if @original_name.in? %i[explain size detailed active_only verbose fields accept_data_loss wait_for_active_shards
                                         include_defaults actions parent_task_id task_id max_concurrent_shard_requests]
    return true if @original_name == :index && spec.description.starts_with?('Comma-separated list of indices to')
    return true if @original_name == :index && spec.description.starts_with?('The name of the')
    return true if @original_name == :index && spec.description.starts_with?('The index in which')
    return true if @original_name == :index && spec.description.starts_with?('Default index')
    return true if @original_name == :index && spec.description.starts_with?('Limit the information')
    return true if @original_name == :index && spec.description.starts_with?('Comma-separated list or wildcard')
    return true if @original_name == :index && spec.description == 'Comma-separated list of indices'
    return true if @original_name == :analyze_wildcard && spec.description.include?('wildcards and prefix queries')
    return true if @original_name == :realtime && spec.description.starts_with?('Specifies if')
    return true if @original_name == :_source && spec.description.ends_with?('sub-request')
    return true if @original_name == :repository && spec.description.ends_with?('Wildcard (`*`) patterns are supported.')
    return true if @original_name == :_source_includes && spec.description.ends_with?('sub-request')
    return true if @original_name == :_source_excludes && spec.description.ends_with?('sub-request')
    return true if @original_name == :_source_excludes && spec.description.ends_with?('sub-request')
    return true if @original_name == :preference && spec.description.ends_with?("'docs'.")
    return true if @original_name == :create && spec.description.include?('dry-run')
    return true if @original_name == :cause && spec.description.include?('creating/updating')
    return true if @original_name == :require_alias && spec.description.include?('require_alias')
    return true if @original_name == :node_id && spec.description.exclude?('_local')
    return true if @original_name == :id && spec.description.include?('a doc param should be supplied')
    return true if name == 'refresh_boolean'
    return true if spec.description.ends_with?('"params" or "docs".')
    false
  end

  def unique_default?
    return true if @original_name.in? %i[explain size detailed expand_wildcards wait_for_active_shards]
    return true if @original_name == :requests_per_second
    return true if @original_name == :realtime && spec.description.starts_with?('Specifies if')
    false
  end

  def unique_deprecation?
    return true if @original_name == :local && spec.deprecated.present?
    false
  end

  def skip_repo?
    return true if original_name.in?(%i[expand_wildcards])
    return true if name == 'master_timeout' && spec.deprecated.nil?
    return true if name == 'wait_for_active_shards' && !spec.description.downcase.include?('default to')
    return true if name.in? %w[requests_per_second ignore_unavailable allow_no_indices]
    false
  end

  def traits
    {
      default: default_value,
      with_default: !default.nil?,
      deprecated: (!!@deprecation unless @deprecation.nil?),
      extensions:,
      with_extensions:,
      documentation:,
      pattern:
    }
  end

  def extensions
    { 'comma-separated-list': (true if type == 'list' && param_type == 'path'),
      'enum-options': (spec.options if param_type == 'path') }
      .merge(deprecation_info).compact.map { |k, v| { key: k, value: v } }
  end

  def with_extensions
    extensions.any?
  end

  def options
    return unless spec.options

    spec.options.map { |option| { key: option.upcase, value: option } }
  end

  def documentation
    return if spec.description.nil?
    description = spec.description.gsub('"', "'").strip
    description[-1] == '.' ? description : "#{description}."
  end

  def default_value
    capture_default
    type.in?(%w[string enum time]) ? "\"#{default}\"" : default
  end

  def capture_default
    return unless description.present?
    return unless default.nil? && description.downcase.include?('default')
    return if type == 'list'
    return spec.default = '1' if description.downcase.include?('defaults to 1')
    return unless description.match?(/.* \(default: (\S*)\).*/)
    value = description[/\(default: (\S*)\)/, 1]
    return if type == 'integer' && value.to_i.zero? && value != '0'
    return if type == 'boolean' && %w[true false].exclude?(value)
    spec.default = value
    spec.description = description.gsub(/( \(default: \S*\))/, '')
  end

  def deprecation_info
    return {} unless @deprecation.is_a? OpenStruct
    { 'deprecation-message': "\"#{@deprecation.description}\"",
      'version-deprecated': "\"#{@deprecation.version}\"" }
  end
end
