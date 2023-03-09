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

  # @param [String] name
  # @param [OpenStruct] spec
  def initialize(name, spec)
    @name = name
    @spec = spec
    @deprecation = @spec.deprecated
  end

  def smithy_type
    @spec.type.capitalize
  end

  def name
    @name.to_s.camelcase
  end

  def traits
    {
      deprecated: (!!@deprecation unless @deprecation.nil?),
      deprecation_info:,
      documentation: @spec.description,
      default: @spec.default
      # TODO: Extract default from description
    }
  end

  private

  def deprecation_info
    return nil unless @deprecation.is_a? OpenStruct
    { deprecation_message: @deprecation.description,
      deprecation_version: @deprecation.version }
  end
end
