# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require 'active_support/all'
require 'ostruct'
require 'json'
require_relative 'operation'
require_relative 'parameter'

# API Action
class Action
  attr_reader :spec, :operation_group

  # @param [Pathname] pathname
  def initialize(pathname)
    @spec = JSON.parse pathname.read, object_class: OpenStruct
    @operation_group = pathname.basename.to_s.split('.')[..-2].join('.')
    @spec = @spec.send @operation_group
  end

  def operations
    return @operations unless @operations.nil?
    ops = spec.url.paths.map { |path| path.methods.map { |method| { path: path.path, method: } } }.flatten
    @operations = ops.map { |hash| Operation.new(operation_group, hash[:path], hash[:method], spec) }
  end

  def description
    description = spec.documentation.description.gsub('"', "'").strip
    description[-1] == '.' ? description : "#{description}."
  end

  def query_params
    @query_params ||= spec.params.to_h.map { |name, spec| Parameter.new name, spec, operation_group }
  end

  def with_body?
    operations.any?(&:with_body?)
  end
end
