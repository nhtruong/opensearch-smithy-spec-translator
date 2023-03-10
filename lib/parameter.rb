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
  attr_reader :spec, :name

  delegate :type, :description, :default, to: :spec

  # @param [String] name
  # @param [OpenStruct] spec
  def initialize(name, spec)
    @pattern = '^([0-9]+)(?:d|h|m|s|ms|micros|nanos)$' if spec.type == 'time'
    spec.type = 'string' if spec.type == 'number|string'
    spec.type = 'integer' if spec.type == 'number'
    spec.type = 'list' if spec.description.starts_with?('A comma-separated')
    @name = name
    @spec = spec
    @deprecation = spec.deprecated
  end

  def smithy_type
    return 'string' if spec.type == 'time'
    spec.type
  end

  def smithy_name
    @name.to_s.camelcase
  end

  def traits
    {
      deprecated: (!!@deprecation unless @deprecation.nil?),
      deprecation_info:,
      documentation: spec.description.gsub('"', "'"),
      pattern: @pattern,
      default: default_value
      # TODO: Extract default from description
    }
  end

  def options
    return unless spec.options

    spec.options.map { |option| { key: option.upcase, value: option } }
  end

  private

  def default_value
    if default.nil? && description.downcase.include?('default')
      puts description
      puts description.match?(/.*\(default: (\S*)\).*/)
    end
    default.is_a?(String) ? "\"#{default}\"" : default
  end

  def deprecation_info
    return nil unless @deprecation.is_a? OpenStruct
    { deprecation_message: @deprecation.description,
      deprecation_version: @deprecation.version }
  end
end
