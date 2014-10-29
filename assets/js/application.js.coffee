##---------------------------------------------##
# Libraries required for the included libraries #
##---------------------------------------------##
#= require_self
#= require vendors/jquery-2.1.1.min
#= require vendors/underscore-min

#= require_tree ./d3
#= require_tree ./vendors


# Global Scope
root = exports ? this

# This is needed to namespace the coffeescript classes
root.Fortune = {}
