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
  attr_reader :spec

  # @param [String] name
  # @param [OpenStruct] spec
  def initialize(name, spec)
    @pattern = '^([0-9]+)(?:d|h|m|s|ms|micros|nanos)$' if spec.type == 'time'
    spec.type = 'string' if %w[number|string time].include?(spec.type)
    @name = name
    @spec = spec
    @deprecation = spec.deprecated
  end

  def category
    @category ||= case @spec.type
                  when 'list' then :lists
                  when 'enum' then :enums
                  when 'string', 'integer', 'boolean' then :simples
                  else raise "Unrecognized Data Type: #{@spec.type}"
                  end
  end

  def smithy_type
    @spec.type
  end

  def name
    @name.to_s.camelcase
  end

  def traits
    {
      deprecated: (!!@deprecation unless @deprecation.nil?),
      deprecation_info:,
      documentation: @spec.description,
      pattern: @pattern,
      default: @spec.default
      # TODO: Extract default from description
    }
  end

  def options
    return unless @spec.options

    @spec.options.map { |option| { key: option.upcase, value: option } }
  end

  private

  def deprecation_info
    return nil unless @deprecation.is_a? OpenStruct
    { deprecation_message: @deprecation.description,
      deprecation_version: @deprecation.version }
  end
end
