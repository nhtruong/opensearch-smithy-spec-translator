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
  attr_reader :spec, :original_name

  delegate :type, :description, :default, to: :spec

  # @param [String] name
  # @param [OpenStruct] spec
  def initialize(name, spec)
    @pattern = '^([0-9]+)(?:d|h|m|s|ms|micros|nanos)$' if spec.type == 'time'
    spec.type = 'string' if spec.type == 'number|string'
    spec.type = 'integer' if spec.type == 'number'
    spec.type = 'list' if spec.description.starts_with?('A comma-separated')
    @original_name = name
    @spec = spec
    @deprecation = spec.deprecated
  end

  def smithy_type
    return 'string' if spec.type == 'time'
    spec.type
  end

  def name
    return @name if @name
    return @name = "#{@original_name}_#{spec.default}" if @original_name == :expand_wildcards
    @name = @original_name.to_s
  end

  def unique_description?
    spec.description.starts_with?('A comma separated list of indices to')
  end

  def skip_repo?
    return true if name == 'master_timeout' && spec.deprecated.nil?
    return true if name == 'wait_for_active_shards' && !spec.description.downcase.include?('default to')
    false
  end

  def smithy_name
    name.to_s.camelcase
  end

  def traits
    {
      default: default_value,
      with_default: !default.nil?,
      deprecated: (!!@deprecation unless @deprecation.nil?),
      deprecation_info:,
      documentation:,
      pattern: @pattern
    }
  end

  def options
    return unless spec.options

    spec.options.map { |option| { key: option.upcase, value: option } }
  end

  private

  def documentation
    return if spec.description.nil?
    description = spec.description.gsub('"', "'").strip
    description[-1] == '.' ? description : "#{description}."
  end

  def default_value
    capture_default
    type.in?(%w[string enum]) ? "\"#{default}\"" : default
  end

  def capture_default
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
    return nil unless @deprecation.is_a? OpenStruct
    { deprecation_message: @deprecation.description,
      deprecation_version: @deprecation.version }
  end
end
