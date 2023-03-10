# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

# API Operation
class Operation
  attr_reader :path, :method

  # @param [String] group
  # @param [Integer | NilClass] index
  # @param [String] path
  # @param [String] method
  # @param [OpenStruct] spec
  def initialize(group, index, path, method, spec)
    @group = group
    @index = index
    @path = path
    @method = method
    @spec = spec
  end

  def name
    name = @group.gsub('.', '_').camelcase
    [name, @index].compact.join('_')
  end

  def input_name
    name = @group.gsub('.', '_').camelcase
    [name, @index, 'Input'].compact.join('_')
  end

  def output_name
    name = @group.gsub('.', '_').camelcase
    [name, @index, 'Output'].compact.join('_')
  end
end