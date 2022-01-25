require "../entity"

module PF
  # This module contains methods to handle circle entity collision
  module CircleCollision
    property radius : Float64 = 1.0

    # Check if two circles are colliding
    def collides_with?(other : Entity)
      distance(other) < radius + other.radius
    end

    # Move objects so that they don't overlap
    def offset_collision(other : Entity)
      d = distance(other)
      overlap = d - radius - other.radius
      offset = ((position - other.position) * (overlap / 2)) / d

      self.position = position - offset
      other.position = other.position + offset
    end

    # Resolve a collision by offsetting the two positions
    # and transfering the momentum
    def resolve_collision(other : Entity)
      offset_collision(other)
      d = distance(other)

      # Calculate the new velocities
      normal_vec = (position - other.position) / d
      tangental_vec = Vector[-normal_vec.y, normal_vec.x]

      # Dot product of velocity with the tangent
      # (the direction in which to bounce towards)
      dp_tangent_a = velocity.dot(tangental_vec)
      dp_tangent_b = other.velocity.dot(tangental_vec)

      # Dot product of the normal
      dp_normal_a = velocity.dot(normal_vec)
      dp_normal_b = other.velocity.dot(normal_vec)

      # conservation of momentum
      ma = (dp_normal_a * (mass - other.mass) + 2.0 * other.mass * dp_normal_b) / (mass + other.mass)
      mb = (dp_normal_b * (other.mass - mass) + 2.0 * mass * dp_normal_a) / (mass + other.mass)

      # Set the new velocities
      self.velocity = (tangental_vec * dp_tangent_a) + (normal_vec * ma)
      other.velocity = (tangental_vec * dp_tangent_b) + (normal_vec * mb)
    end
  end
end
