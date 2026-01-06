# require "./transform2d"
#
# module PF
#   class View
#     @transform : PF2d::Transform = PF2d::Transform.new
#
#     property zoom = 1.0
#     property pan : PF2d::Vec(Float64) = PF2d::Vec[0.0, 0.0]
#     property rotation = 0.0
#
#     def initialize
#     end
#
#     def to_screen(point : Vector)
#       point + pan
#     end
#
#     def from_screen(point : Vector)
#       point - pan
#     end
#   end
# end
