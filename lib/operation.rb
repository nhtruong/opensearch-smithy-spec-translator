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
  attr_reader :path, :method, :spec, :deprecation

  # @param [String] group
  # @param [String] path
  # @param [String] method
  # @param [Boolean] uniform_method
  # @param [OpenStruct] spec
  def initialize(group, path, method, uniform_method, spec)
    @group = group
    @path = path
    @method = method
    @uniform_method = uniform_method
    @spec = spec
    @deprecation = spec.url.paths.find { |p| p.path == path }&.deprecated
  end

  def deprecated
    !!deprecation unless deprecation.nil?
  end

  def name
    @name ||= [name_prefix, @uniform_method ? nil : method.capitalize, name_suffix, disambiguator].compact.join '_'
  end

  def input_name
    [name, 'Input'].join('_')
  end

  def output_name
    [name_prefix, 'Output'].compact.join('_')
  end

  def path_params
    @path_params ||= spec.url.paths.find { |path| path.path == @path }.parts.to_h
                          &.map { |name, spec| Parameter.new name, spec, @group, 'path' }
  end

  def with_body?
    @method.in?(%w[POST PUT DELETE]) && spec.body.present?
  end

  def body_required?
    with_body? && spec.body.required
  end

  def delete_with_body?
    @method == 'DELETE' && spec.body.present?
  end

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

  def disambiguator
    case @group
    when 'nodes.hot_threads'
      return if deprecation.nil?
      tail = nil
      tail = :Dash if path.include?('hot_threads')
      tail ||= :Cluster if path.include?('cluster')
      ['Deprecated', tail].compact.join
    when 'indices.delete_alias', 'indices.put_alias'
      'Plural' if path.include?('_aliases')
    end
  end
end
