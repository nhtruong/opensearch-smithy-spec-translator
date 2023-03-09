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
    # raise collision_message(@repo, name, spec) if @repo.include?(name) && @repo[name].spec != spec
    @repo[name] = param
  end

  def filter_by_type(type)
    @repo.values.select { |param| param.spec.type == type.to_s }
  end

  private

  def collision_message(repo, name, info)
    "#{name} has already been used \n" \
      "#{info.to_json} \n" \
      "#{repo[name].to_json} \n"
  end
end

