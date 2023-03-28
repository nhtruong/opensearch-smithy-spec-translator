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
  attr_reader :path, :method, :spec

  # @param [String] group
  # @param [String] path
  # @param [String] method
  # @param [OpenStruct] spec
  def initialize(group, path, method, spec)
    @group = group
    @path = path
    @method = method
    @spec = spec
  end

  def name
    @name ||= [name_prefix, method.capitalize, name_suffix].compact.join '_'
  end

  def input_name
    [name, 'Input'].compact.join('_')
  end

  def output_name
    [name_prefix, 'Output'].compact.join('_')
  end

  def path_params
    @path_params ||= spec.url.paths.find { |path| path.path == @path }.parts.to_h
                          &.map { |name, spec| Parameter.new name, spec, @group }
  end

  def with_body?
    @method == 'POST' || @method == 'PUT'
  end

  private

  def name_prefix
    @name_prefix ||= @group.gsub('.', '_').camelcase
  end

  def name_suffix
    shortest = spec.url.paths.map { |path| (path.parts&.to_h&.keys || []).to_set }.min_by(&:size)
    diff = path_params&.map(&:original_name)&.to_set&.difference(shortest)
    return nil if diff.empty?
    suffix = diff.to_a.sort.map { |name| name.to_s.camelcase }.join
    "With#{suffix}"
  end
end
