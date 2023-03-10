# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require 'ostruct'
require 'forwardable'
require 'active_support/all'

# Repository for shared params
class ParamsRepository
  attr_reader :repo

  def initialize
    @repo = {}
  end

  # @param [Array<Parameter>] params
  def add_many(params)
    params.each { |param| add_one param }
  end

  # @param [Parameter] param
  def add_one(param)
    name = param.name
    spec = param.spec
    # TODO: Handle Collisions
    # raise collision_message(name, spec) if @repo.include?(name) && @repo[name].spec != spec
    @repo[name] = param
  end

  def filter_by_type(type)
    @repo.values.select { |param| param.smithy_type == type.to_s }.sort_by(&:type)
  end

  private

  def collision_message(name, spec)
    "#{name} has already been used \n" \
      "#{spec} \n" \
      "#{@repo[name].spec} \n"
  end
end

